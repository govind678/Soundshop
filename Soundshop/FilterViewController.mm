//
//  FilterViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/25/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//
//  Recorded Input Buffer: (Float32) inputBuffer
//  Input Buffer Size: (int) inputBufferSize


#include <stdio.h>
#import "FilterViewController.h"
#import "EAFWrite.h"
#import "EAFRead.h"

#define SampleRate 44100.0

@interface FilterViewController ()

@end

@implementation FilterViewController

@synthesize playPauseResultButton, resultProgress, inputBuffer, inputBufferSize, channelCount;
@synthesize resultAudioPlayer;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Update Audio Progress
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePlayProgress) userInfo:nil repeats:YES];
    
    
    // Setup outURL
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"result.caf"];
    
    outURL = [NSURL fileURLWithPath:soundFilePath];

    
    
    // Create URLs from IR Files
    stairwell1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Stairwell1.caf", [[NSBundle mainBundle] resourcePath]]];
    hall1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Hall1.caf", [[NSBundle mainBundle] resourcePath]]];
    bathroom1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Bathroom1.caf", [[NSBundle mainBundle] resourcePath]]];
    
    // Setup IR Buffer Sizes
    stairwell1Duration =  3.430884;
    hall1Duration = 0.768730;
    bathroom1Duration = 0.9; // Must change
    
    // Setup ExtAudioFile Writer & Reader
    writer = [[EAFWrite alloc]init];
    reader = [[EAFRead alloc]init];
    
    
    // Log Input Buffer
    /*for( int i=0; i<inputBufferSize; i++ ) {
     Float32 currentSample = inputBuffer[i];
     NSLog(@"currentSample: %f", currentSample);
     }*/
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//*** Return to Home Screen ***//
- (IBAction)returnHome:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}


//*** Update Playback ProgressView ***//
- (void)updatePlayProgress {
    float progress = [resultAudioPlayer currentTime] / [resultAudioPlayer duration];
    self.resultProgress.progress = progress;
}



//*** Play Result Audio File ***//
- (IBAction)playResult:(UIBarButtonItem *)sender {
    
    if (resultAudioPlayer == nil) {
		NSLog(@"Error, Nil Audio Player");
    } else {
        if(!resultAudioPlayer.playing) {
            [resultAudioPlayer play];
            playPauseResultButton.title = @"Pause";
            NSLog(@"Play");
        } else {
            [resultAudioPlayer pause];
            playPauseResultButton.title = @"Play";
            NSLog(@"Pause");
        }
    }
}



//*** Rewind Result Audio File ***//
- (IBAction)rewindResult:(UIBarButtonItem *)sender {
    
    [resultAudioPlayer stop];
    [resultAudioPlayer setCurrentTime:0];
    playPauseResultButton.title = @"Play";
}




//*** Write Out Buffer to CAF File ***//
- (IBAction)process:(UIBarButtonItem *)sender {
    
    [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
    
    outBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        outBuffer[i] = (float*)calloc(inputBufferSize, sizeof(float));
    
    
    // For debugging: Write input as CAF file
    outBuffer = &inputBuffer;
    
    [writer writeFloats:inputBufferSize fromArray:outBuffer];
    
    NSError *error;
	resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
    resultAudioPlayer.delegate = self;
    NSLog(@"%@",error.description);

}



//*** Reverb Implementations ***//

- (IBAction)applyStairwell:(UIButton *)sender {
    
    // Setup ExtAudioFile Reader
    float duration = stairwell1Duration;
    IRBufferSize = duration*SampleRate;
    
    [reader openFileForRead:stairwell1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];
    
    
    /*//Log IR Buffer
     for(int j=0; j<channelCount; j++) {
     for( int i=0; i<IRBufferSize; i++ ) {
     float currentSample = IRBuffer[j][i];
     NSLog(@"sample[%i]: %f", i, currentSample);
     }
     }*/
    
    /*//Log Input Buffer
     for( int i=0; i<inputBufferSize; i++ ) {
     Float32 currentSample = inputBuffer[i];
     NSLog(@"currentSample: %f", currentSample);
     } */

}


- (IBAction)applyHall:(UIButton *)sender {
    
    // Setup ExtAudioFile Reader
    float duration = hall1Duration;
    IRBufferSize = duration*SampleRate;
    
    [reader openFileForRead:hall1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];
    
}


- (IBAction)applyBathroom:(UIButton *)sender {
    
    // Setup ExtAudioFile Reader
    float duration = bathroom1Duration;
    IRBufferSize = duration*SampleRate;
    
    [reader openFileForRead:bathroom1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];

}




//*** AVAudioPlayer Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playPauseResultButton.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}


@end