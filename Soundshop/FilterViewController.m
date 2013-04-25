//
//  FilterViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/25/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//
//  Recorded Input Buffer: (Float32) inputBuffer
//  Input Buffer Size: (int) inputBufferSize


#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

@synthesize playPauseResultButton, resultProgress, inputBuffer, inputBufferSize;


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
    
    // Update Audio Progress
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePlayProgress) userInfo:nil repeats:YES];
    
    
    // Create URLs from IR Files
    stairwell1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Stairwell1.caf", [[NSBundle mainBundle] resourcePath]]];
    hall1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Hall1.caf", [[NSBundle mainBundle] resourcePath]]];

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//*** Return to Home Screen ***//
- (IBAction)returnHome:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}


//*** Update Playback ProgressView ***//
- (void)updatePlayProgress {
    float progress = [resultAudioPlayer currentTime] / [resultAudioPlayer duration];
    self.resultProgress.progress = progress;
}



//*** Play Result Audio File ***//
- (IBAction)playResult:(UIBarButtonItem *)sender {
    
    NSError *error;
	resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:resultFileURL error:&error];
    
    if (resultAudioPlayer == nil) {
		NSLog(@"%@",error);
    } else {
        if(!resultAudioPlayer.playing) {
            [resultAudioPlayer play];
            playPauseResultButton.title = @"Pause";
            NSLog(@"Play");
        } else {
            [resultAudioPlayer pause];
            playPauseResultButton.title = @"Play";
            NSLog(@"Pause");
        }
    }
}



//*** Rewind Result Audio File ***//
- (IBAction)rewindResult:(UIBarButtonItem *)sender {
    
    [resultAudioPlayer stop];
    [resultAudioPlayer setCurrentTime:0];
    playPauseResultButton.title = @"Play";
}



//*** Apply Reverb Effect ***//
- (IBAction)applyReverb:(UIButton *)sender {
    
    // Convert IR to Float32 array (select appropriate NSURL)
    Float32 *floatIRBuffer = [self floatExtract:stairwell1];
    
    for( int i=0; i<IRBufferSize; i++ ) {
        Float32 currentSample = floatIRBuffer[i];
        NSLog(@"currentSample: %f", currentSample);
    }
}





//*** Extended Audio File Services ***//
- (Float32 *)floatExtract: (NSURL *)IRFile {
    
    //* (Float32) Audio Buffer: floatAudioBuffer
    //* (int)Size of Buffer: bufferSize
    
    // Open Extended Audio File
    CFURLRef impulseResponse = ((CFURLRef)CFBridgingRetain(IRFile));
    ExtAudioFileRef fileRef;
    CheckResult(ExtAudioFileOpenURL(impulseResponse, &fileRef), "ExtAudioFileOpenURL failed");
    
    
    // Set up audio format
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate = 44100;
	audioFormat.mFormatID = kAudioFormatLinearPCM;
	audioFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
	audioFormat.mBitsPerChannel = sizeof(Float32) * 8;
	audioFormat.mChannelsPerFrame = 1; // set this to 2 for stereo
	audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(Float32);
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    
    
    // Apply audio format to Extended Audio File
	CheckResult(ExtAudioFileSetProperty(fileRef,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        sizeof (AudioStreamBasicDescription),
                                        &audioFormat),
				"Couldn't set client data format on input ext file");
    
    
    // Set up AudioBufferList
	UInt32 outputBufferSize = 32 * 1024; // 32 KB
	UInt32 sizePerPacket = audioFormat.mBytesPerPacket;
	UInt32 packetsPerBuffer = outputBufferSize / sizePerPacket;
	UInt8 *outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
	AudioBufferList convertedData;
	convertedData.mNumberBuffers = 1;
	convertedData.mBuffers[0].mNumberChannels = audioFormat.mChannelsPerFrame;
	convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
	convertedData.mBuffers[0].mData = outputBuffer;
    
	// Read Extended Audio File into AudioBufferList
	UInt32 frameCount = packetsPerBuffer;
	CheckResult(ExtAudioFileRead(fileRef,
                                 &frameCount,
                                 &convertedData),
				"ExtAudioFileRead failed");
	
    
    Float32 *floatBuffer;
    
    // Log float values of AudioBufferList
	for (int y=0; y<convertedData.mNumberBuffers; y++) {
        NSLog(@"buffer# %u", y);
        AudioBuffer audioBuffer = convertedData.mBuffers[y];
        IRBufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
        floatBuffer = audioBuffer.mData;
     }
    
    //NSLog(@"Float Extract: %f",*floatBuffer);
    return (floatBuffer);
}




static void CheckResult(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	char errorString[20];
	// See if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
	if (isprint(errorString[1]) && isprint(errorString[2]) &&
		isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// No, format it as an integer
		sprintf(errorString, "%d", (int)error);
	
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}




//*** AVAudioPlayer Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playPauseResultButton.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}


@end
