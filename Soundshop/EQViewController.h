//
//  EQViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/28/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EAFWrite.h"

@interface EQViewController : UIViewController <AVAudioPlayerDelegate> {
    
    AVAudioPlayer *audioPlayer;
    
    NSURL *outURL;
    
    EAFWrite *writer;
    float **outBuffer;
    float **IRBuffer;
    long IRBufferSize;
    
}

@property (nonatomic) Float32* inputBuffer;
@property (nonatomic) long inputBufferSize;
@property (nonatomic) int channelCount;


- (IBAction)switchHomeView:(UIBarButtonItem *)sender;
- (IBAction)playResult:(UIBarButtonItem *)sender;
- (IBAction)rewindResult:(UIBarButtonItem *)sender;
- (IBAction)processAudio:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UISlider *bassSlider;
@property (weak, nonatomic) IBOutlet UISlider *midSlider;
@property (weak, nonatomic) IBOutlet UISlider *trebleSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *resultProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPauseButton;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end
