//
//  viewWaveformViewController.h
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface viewWaveformViewController : UIViewController {
    
}

- (IBAction)switchHome:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *waveformImageView;

@end
