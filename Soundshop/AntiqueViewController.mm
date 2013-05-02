//
//  AntiqueViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 5/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "AntiqueViewController.h"
#import "EAFWrite.h"

@interface AntiqueViewController ()

@end

@implementation AntiqueViewController

@synthesize playAntique, resultProgress;
@synthesize inputBuffer, inputBufferSize, channelCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    // Setup outURL
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"result.caf"];
    antiqueURL = [NSURL fileURLWithPath:soundFilePath];
    
    writer = [[EAFWrite alloc]init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyPhone:(UIButton *)sender {
}

- (IBAction)applyVinyl:(UIButton *)sender {
}

- (IBAction)returnHome:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}

- (IBAction)play:(UIBarButtonItem *)sender {
    if (resultAudioPlayer == nil) {
		NSLog(@"Error, Nil Audio Player");
    } else {
        if(!resultAudioPlayer.playing) {
            [resultAudioPlayer play];
            playAntique.title = @"Pause";
            NSLog(@"Play");
        } else {
            [resultAudioPlayer pause];
            playAntique.title = @"Play";
            NSLog(@"Pause");
        }
    }

}

- (IBAction)rewind:(UIBarButtonItem *)sender {
    
    [resultAudioPlayer stop];
    [resultAudioPlayer setCurrentTime:0];
    playAntique.title = @"Play";
}




- (void)updateProgress {
    float progress = [resultAudioPlayer currentTime] / [resultAudioPlayer duration];
    self.resultProgress.progress = progress;
}



//*** AVAudioPlayer Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playAntique.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}



@end
