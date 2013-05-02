//
//  AntiqueViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 5/2/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EAFWrite.h"
#include "dsp.h"

@interface AntiqueViewController : UIViewController <AVAudioPlayerDelegate> {
    
    NSURL *antiqueURL;
    
    EAFWrite *writer;
    float **outBuffer;
    
}

- (IBAction)applyPhone:(UIButton *)sender;
- (IBAction)applyVinyl:(UIButton *)sender;

@property AVAudioPlayer *resultAudioPlayer;

@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;
- (IBAction)switchHome:(UIBarButtonItem *)sender;
- (IBAction)playResult:(UIBarButtonItem *)sender;
- (IBAction)rewindResult:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playAntiqueButton;

- (void) updateProgress;


@property (nonatomic) Float32* inputBuffer;
@property (nonatomic) uint32_t inputBufferSize;
@property (nonatomic) int channelCount;

@property (nonatomic) NSURL* inURL;


@end
