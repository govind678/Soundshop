//
//  SoundshopViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "SoundshopViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "viewWaveformViewController.h"

@interface SoundshopViewController ()

@end

@implementation SoundshopViewController

@synthesize playPauseButton, recordButton, audioPlayer, audioRecorder;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //NSString *stringPath = [[NSBundle mainBundle]pathForResource:@"myAudio" ofType:@"mp3"];
    //NSURL *url = [NSURL fileURLWithPath:stringPath];
    //audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    //[audioPlayer setVolume:self.volumeSliderOutlet.value];

    
    NSError *error;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMyProgress) userInfo:nil repeats:YES];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];

    
    audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    
    
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
        
        NSError *error;
        
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:audioRecorder.url
                       error:&error];
        
        audioPlayer.delegate = self;
        
        NSLog(@"Stop Record");
    }
}

- (IBAction)switchViewWaveform:(id)sender {
    viewWaveformViewController *viewWaveform = [[viewWaveformViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewWaveform animated:YES completion:NO];
}


- (IBAction)rewind:(UIBarButtonItem *)sender {
    
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    playPauseButton.title = @"Play";
    
    NSLog(@"Rewind");
}



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
