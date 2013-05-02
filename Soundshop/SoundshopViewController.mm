//
//  SoundshopViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#include <stdio.h>
#import "SoundshopViewController.h"
#import "FilterViewController.h"
#import "EQViewController.h"
#import "AntiqueViewController.h"
#import "EAFRead.h"

#define SampleRate 44100.0


@interface SoundshopViewController ()

@end

@implementation SoundshopViewController

@synthesize playPauseButton, recordButton, audioPlayer, audioRecorder, scrollWaveform;
@synthesize reader;

- (void)viewDidLoad
{
    [super viewDidLoad];
	

    //*** Setup AV Recorded ***//
    
    NSError *error;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMyProgress) userInfo:nil repeats:YES];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    
    inURL = [NSURL fileURLWithPath:soundFilePath];
    
    channelCount = 1;
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: channelCount], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:SampleRate], AVSampleRateKey,
                                    nil];

    
    audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:inURL
                      settings:recordSettings
                      error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }

    
    

    
    
    /* random test code for myConv
    
    float *signal, *filter, *result;
    uint32_t lenSignal, filterLength,resultLength;
    uint32_t i;
    
    filterLength = 256;
    resultLength = 2048;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    signal = (float*) malloc(lenSignal * sizeof(float));
    filter = (float*) malloc(filterLength * sizeof(float));
    result = (float*) malloc(resultLength * sizeof(float));
    
    if (signal == NULL || filter == NULL || result == NULL) {
        printf("\nmalloc failed to allocate memory for the "
               "convolution sample.\n");
        exit(0);
    }
    
    for (i = 0; i < lenSignal; i++)
        signal[i] = 1.0;
    
    for (i = 0; i < filterLength; i++)
        filter[i] = 1.0;
    
    result = myConv(signal, filter, lenSignal, filterLength, resultLength);
                             
    */
    

    
    // Initialize ExtAudioFile Reader
    reader = [[EAFRead alloc]init];
    
    
    // Setup Scroll View to Draw Waveform
    [scrollWaveform setContentSize:CGSizeMake(900, 600)];
    
    
    
    stairwell1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Stairwell1.caf", [[NSBundle mainBundle] resourcePath]]];
    hall1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Hall1.caf", [[NSBundle mainBundle] resourcePath]]];
    bathroom1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Bathroom1.caf", [[NSBundle mainBundle] resourcePath]]];
    
    
    //*** Read IR Files into Buffers ***//
    // Setup IR Buffer Sizes
    stairwell1Size =  3.430884 * SampleRate;
    hall1Size = 0.768730 * SampleRate;
    bathroom1Size = 0.9 * SampleRate; // Must change
    
    [reader openFileForRead:stairwell1 sr:SampleRate channels:1];
    [reader openFileForRead:hall1 sr:SampleRate channels:1];
    [reader openFileForRead:bathroom1 sr:SampleRate channels:1];
    
    stairwell1Buffer = (float **)calloc(channelCount, sizeof(float*));
    hall1Buffer = (float **)calloc(channelCount, sizeof(float*));
    bathroom1Buffer = (float **)calloc(channelCount, sizeof(float*));
    
    for (int i = 0; i < channelCount; ++i) {
        stairwell1Buffer[i] = (float*)calloc(stairwell1Size, sizeof(float));
        hall1Buffer[i] = (float*)calloc(hall1Size, sizeof(float));
        bathroom1Buffer[i] = (float*)calloc(bathroom1Size, sizeof(float));
    }
    
    [reader readFloatsConsecutive:stairwell1Size intoArray:stairwell1Buffer];
    [reader readFloatsConsecutive:hall1Size intoArray:hall1Buffer];
    [reader readFloatsConsecutive:bathroom1Size intoArray:bathroom1Buffer];
    
    
}




- (void)updateMyProgress {
    float progress = [audioPlayer currentTime]/[audioPlayer duration];
    self.audioProgress.progress = progress;
    
}



- (IBAction)changeVolumeSlider:(UISlider *)sender {
    [audioPlayer setVolume:sender.value];
}




- (IBAction)playPause:(UIBarButtonItem *)sender {
    
    if(!audioPlayer.playing) {
        [audioPlayer play];
        playPauseButton.title = @"Pause";
        NSLog(@"Play");
    } else {
        [audioPlayer pause];
        playPauseButton.title = @"Play";
        NSLog(@"Pause");
    }
    
    /*for( int i=0; i<numFrames; i++ ) {
        float currentSample = inBuffer[i];
        NSLog(@"currentSample: %f", currentSample);
    }*/
    
}



- (IBAction)record:(UIBarButtonItem *)sender {
    
    if (!audioRecorder.recording) {
        [audioRecorder record];
        recordButton.title = @"Stop";
        self.view.backgroundColor = [UIColor colorWithRed:0.352f green:0.202f blue:0.05f alpha:1.0f];
        NSLog(@"Record");
    } else {
        [audioRecorder stop];
        recordButton.title = @"Record";
        self.view.backgroundColor = [UIColor colorWithRed:0.09f green:0.282f blue:0.435f alpha:1.0f];
        
        
        //*** Setup AV Audio Player ***//
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
        audioPlayer.delegate = self;
        
        NSLog(@"Stop Record");
        
        
        //*** Setup ExtAudioFile Reader ***//
        float duration = [audioPlayer duration];
        NSLog(@"Duration: %f",duration);
        numFrames = duration*SampleRate;

        [reader openFileForRead:audioRecorder.url sr:SampleRate channels:1];
        
        
        
        inBuffer = (float **)calloc(channelCount, sizeof(float*));
        for (int i = 0; i < channelCount; ++i)
            inBuffer[i] = (float*)calloc(numFrames, sizeof(float));
        
        [reader readFloatsConsecutive:numFrames intoArray:inBuffer];
       

        /*for(int j=0; j<channelCount; j++) {
            for( int i=0; i<numFrames; i++ ) {
                float currentSample = inBuffer[j][i];
                NSLog(@"sample[%i]: %f", i, currentSample);
            }
        }*/
        
    }
}



//*** Switch to Filter View ***//
- (IBAction)switchViewWaveform:(id)sender {
    //viewWaveformViewController *viewWaveform = [[viewWaveformViewController alloc] initWithNibName:nil bundle:nil];
    //[self presentViewController:viewWaveform animated:YES completion:NO];
    if(audioPlayer != nil) {
        FilterViewController *viewFilterScreen = [[FilterViewController alloc] initWithNibName:nil bundle:nil];
        viewFilterScreen.inputBuffer = *(inBuffer);
        viewFilterScreen.inputBufferSize = numFrames;
        viewFilterScreen.channelCount = channelCount;
        viewFilterScreen.stairwell1Buffer = *(stairwell1Buffer);
        viewFilterScreen.hall1Buffer = *(hall1Buffer);
        viewFilterScreen.bathroom1Buffer = *(bathroom1Buffer);
        viewFilterScreen.stairwell1Size = stairwell1Size;
        viewFilterScreen.hall1Size = hall1Size;
        viewFilterScreen.bathroom1Size = bathroom1Size;
        viewFilterScreen.inURL = inURL;
        [self presentViewController:viewFilterScreen animated:YES completion:NO];
    }
    
    
}

- (IBAction)switchAntique:(UIBarButtonItem *)sender {
    if(audioPlayer != nil) {
        AntiqueViewController *viewAntiqueScreen = [[AntiqueViewController alloc] initWithNibName:nil bundle:nil];
        viewAntiqueScreen.inputBuffer = *(inBuffer);
        viewAntiqueScreen.inputBufferSize = numFrames;
        viewAntiqueScreen.channelCount = channelCount;
        viewAntiqueScreen.inURL = inURL;
        [self presentViewController:viewAntiqueScreen animated:YES completion:NO];
    }

    
}


- (IBAction)switchEQView:(UIBarButtonItem *)sender {
    if(audioPlayer != nil) {
        EQViewController *viewEQScreen = [[EQViewController alloc]initWithNibName:nil bundle:nil];
        viewEQScreen.inputBuffer = *(inBuffer);
        viewEQScreen.inputBufferSize = numFrames;
        viewEQScreen.channelCount = channelCount;
        viewEQScreen.inURL = inURL;
        [self presentViewController:viewEQScreen animated:YES completion:NO];
    }
    
}



- (IBAction)rewind:(UIBarButtonItem *)sender {
    
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    playPauseButton.title = @"Play";
    
    NSLog(@"Rewind");
}







//*** AVPlayer/Recorder Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playPauseButton.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording: (AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Finished Recording");
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occurred");
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
