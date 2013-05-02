//
//  AntiqueViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 5/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EAFWrite.h"
#include "dsp.h"


@interface AntiqueViewController : UIViewController <AVAudioPlayerDelegate> {
    
    AVAudioPlayer *resultAudioPlayer;
    
    NSURL *antiqueURL;
    
    EAFWrite *writer;
    float **outBuffer;
    
}

- (IBAction)applyPhone:(UIButton *)sender;

- (IBAction)applyVinyl:(UIButton *)sender;


- (IBAction)returnHome:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playAntique;
- (IBAction)play:(UIBarButtonItem *)sender;
- (IBAction)rewind:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIProgressView *resultProgress;

- (void) updateProgress;



@property (nonatomic) Float32* inputBuffer;
@property (nonatomic) uint32_t inputBufferSize;
@property (nonatomic) int channelCount;

@end
