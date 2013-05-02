//
//  FilterViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/25/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import "EAFWrite.h"
#import "EAFRead.h"

#include "dsp.h"


@interface FilterViewController : UIViewController <AVAudioPlayerDelegate> {
    
    AVAudioPlayer *resultAudioPlayer;
    NSURL *outURL;
    
    // IR File URLs
    //NSURL *stairwell1;
    //NSURL *hall1;
    //NSURL *bathroom1;
    
    //float stairwell1Duration;
    //float hall1Duration;
    //float bathroom1Duration;
    
    
    //EAFRead *reader;
    EAFWrite *writer;
    float **outBuffer;
    //float **IRBuffer;
    //long IRBufferSize;
    int sqWaveFlag;
    
}

- (IBAction)reverbFunction:(UISwitch *)sender;

- (IBAction)returnHome:(UIBarButtonItem *)sender;

- (IBAction)playResult:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPauseResultButton;

- (IBAction)rewindResult:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIProgressView *resultProgress;

- (IBAction)process:(UIBarButtonItem *)sender;

- (IBAction)applyStairwell:(UIButton *)sender;
- (IBAction)applyHall:(UIButton *)sender;
- (IBAction)applyBathroom:(UIButton *)sender;



- (void)updatePlayProgress;


@property (nonatomic) Float32* inputBuffer;
@property (nonatomic) uint32_t inputBufferSize;
@property (nonatomic) int channelCount;

@property (nonatomic) Float32* stairwell1Buffer;
@property (nonatomic) Float32* hall1Buffer;
@property (nonatomic) Float32* bathroom1Buffer;

@property (nonatomic) uint32_t stairwell1Size;
@property (nonatomic) uint32_t hall1Size;
@property (nonatomic) uint32_t bathroom1Size;

@property (nonatomic) NSURL* inURL;



@property (weak, nonatomic) IBOutlet UISlider *reverbParam;


@property (strong, nonatomic) AVAudioPlayer *resultAudioPlayer;


@end
