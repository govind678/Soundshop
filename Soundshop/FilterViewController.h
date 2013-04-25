//
//  FilterViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/25/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FilterViewController : UIViewController {
    
    AVAudioPlayer *resultAudioPlayer;
    NSURL *resultFileURL;
    
    // IR File URLs
    NSURL *stairwell1;
    NSURL *hall1;
    
    int IRBufferSize;
    
}


- (IBAction)returnHome:(UIBarButtonItem *)sender;

- (IBAction)playResult:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPauseResultButton;

- (IBAction)rewindResult:(UIBarButtonItem *)sender;

- (IBAction)applyReverb:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIProgressView *resultProgress;

- (Float32 *)floatExtract: (NSURL *)IRFile;
static void CheckResult(OSStatus error, const char *operation);

- (void)updatePlayProgress;


@property (nonatomic) Float32* inputBuffer;
@property (nonatomic) int inputBufferSize;


@end
