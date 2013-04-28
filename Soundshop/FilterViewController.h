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
    NSURL *stairwell1;
    NSURL *hall1;
    NSURL *bathroom1;
    
    long stairwell1Duration;
    long hall1Duration;
    long bathroom1Duration;
    
    
    EAFRead *reader;
    EAFWrite *writer;
    float **outBuffer;
    float **IRBuffer;
    long IRBufferSize;
    
}


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
@property (nonatomic) long inputBufferSize;
@property (nonatomic) int channelCount;


@property (strong, nonatomic) AVAudioPlayer *resultAudioPlayer;


@end
