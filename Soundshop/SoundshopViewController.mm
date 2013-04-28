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
    
    NSURL *inURL = [NSURL fileURLWithPath:soundFilePath];
    
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
    
    FilterViewController *viewFilterScreen = [[FilterViewController alloc] initWithNibName:nil bundle:nil];
    viewFilterScreen.inputBuffer = *(inBuffer);
    viewFilterScreen.inputBufferSize = numFrames;
    viewFilterScreen.channelCount = channelCount;
    [self presentViewController:viewFilterScreen animated:YES completion:NO];
    
}


- (IBAction)switchEQView:(UIBarButtonItem *)sender {
    
    EQViewController *viewEQScreen = [[EQViewController alloc]initWithNibName:nil bundle:nil];
    viewEQScreen.inputBuffer = *(inBuffer);
    viewEQScreen.inputBufferSize = numFrames;
    viewEQScreen.channelCount = channelCount;
    [self presentViewController:viewEQScreen animated:YES completion:NO];
    
    
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
