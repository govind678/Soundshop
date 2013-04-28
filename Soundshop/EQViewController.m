//
//  EQViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/28/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "EQViewController.h"
#import "EAFWrite.h"

#define SampleRate 44100.0

@interface EQViewController ()

@end

@implementation EQViewController

@synthesize bassSlider, midSlider, trebleSlider, audioPlayer, resultProgress, playPauseButton;
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
    
    // Update Audio Progress
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePlayProgress) userInfo:nil repeats:YES];
    
    
    // Setup outURL
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"result.caf"];
    
    outURL = [NSURL fileURLWithPath:soundFilePath];
    
    
    
    writer = [[EAFWrite alloc]init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchHomeView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}



- (IBAction)playResult:(UIBarButtonItem *)sender {
    if (audioPlayer == nil) {
		NSLog(@"Error, Nil Audio Player");
    } else {
        if(!audioPlayer.playing) {
            [audioPlayer play];
            playPauseButton.title = @"Pause";
            NSLog(@"Play");
        } else {
            [audioPlayer pause];
            playPauseButton.title = @"Play";
            NSLog(@"Pause");
        }
    }

}


- (IBAction)rewindResult:(UIBarButtonItem *)sender {
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    playPauseButton.title = @"Play";
}



- (IBAction)processAudio:(UIBarButtonItem *)sender {
    
    float bass = bassSlider.value;
    float mid = midSlider.value;
    float treble = trebleSlider.value;
    
    
    
    
    
    [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
    
    outBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        outBuffer[i] = (float*)calloc(inputBufferSize, sizeof(float));
    
    
    // For debugging: Write input as CAF file
    outBuffer = &inputBuffer;
    
    [writer writeFloats:inputBufferSize fromArray:outBuffer];
    
    NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
    audioPlayer.delegate = self;
    NSLog(@"%@",error.description);

}



//*** Update Playback ProgressView ***//
- (void)updatePlayProgress {
    float progress = [audioPlayer currentTime] / [audioPlayer duration];
    self.resultProgress.progress = progress;
}





//*** AVAudioPlayer Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playPauseButton.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}


@end
