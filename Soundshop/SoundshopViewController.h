//
//  SoundshopViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundshopViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    BOOL isPlaying;
    BOOL isRecording;
}

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIProgressView *audioProgress;

@property (weak, nonatomic) IBOutlet UISlider *volumeSliderOutlet;
- (IBAction)changeVolumeSlider:(UISlider *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPauseButton;
- (IBAction)playPause:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rewindButton;
- (IBAction)rewind:(UIBarButtonItem *)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordButton;
- (IBAction)record:(UIBarButtonItem *)sender;

- (IBAction)switchViewWaveform:(id)sender;



@end
