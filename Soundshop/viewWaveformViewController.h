//
//  viewWaveformViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface viewWaveformViewController : UIViewController {
    
    AVAudioPlayer *resultAudioPlayer;
    
    NSURL *stairwell1;
    NSURL *hall1;
    
    int currentBufferSize;
    
}

- (IBAction)switchHome:(id)sender;


- (IBAction)applyReverb:(UIButton *)sender;


- (IBAction)playOutput:(UIBarButtonItem *)sender;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playOutputButton;

- (IBAction)rewindOutput:(UIBarButtonItem *)sender;

- (Float32)floatExtract: (NSURL *)IRFile;

@end
