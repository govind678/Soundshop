//
//  SoundshopViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "SoundshopViewController.h"
#import "viewWaveformViewController.h"


@interface SoundshopViewController ()

@end

@implementation SoundshopViewController

@synthesize playPauseButton, recordButton, audioPlayer, audioRecorder, scrollWaveform;

- (void)viewDidLoad
{
    [super viewDidLoad];
	

    //*** Setup AV Recorded ***//
    
    NSError *error;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMyProgress) userInfo:nil repeats:YES];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    
    soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];

    
    audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    
    
    /* random test code for myConv
    
    float *signal, *filter, *result;
    uint32_t lenSignal, filterLength,resultLength;
    uint32_t i;
    
    filterLength = 256;
    resultLength = 2048;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    signal = (float*) malloc(lenSignal * sizeof(float));
    filter = (float*) malloc(filterLength * sizeof(float));
    result = (float*) malloc(resultLength * sizeof(float));
    
    if (signal == NULL || filter == NULL || result == NULL) {
        printf("\nmalloc failed to allocate memory for the "
               "convolution sample.\n");
        exit(0);
    }
    
    for (i = 0; i < lenSignal; i++)
        signal[i] = 1.0;
    
    for (i = 0; i < filterLength; i++)
        filter[i] = 1.0;
    
    result = myConv(signal, filter, lenSignal, filterLength, resultLength);
                             
    */
    

    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    


    
    [scrollWaveform setContentSize:CGSizeMake(900, 600)];
    
    
    //*** Setup Drawing Waveforms ***//
    //waveformDrawObject = [[WaveformImageVew alloc] initWithUrl:soundFileURL];
    
    /*
     AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:audioRecorder.url options:nil];

    NSError *assetError = nil;
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return;
	}
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
    
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];*/
    
    
    
}




- (void)updateMyProgress {
    float progress = [audioPlayer currentTime]/[audioPlayer duration];
    self.audioProgress.progress = progress;
    
}



- (IBAction)changeVolumeSlider:(UISlider *)sender {
    [audioPlayer setVolume:sender.value];
}




- (IBAction)playPause:(UIBarButtonItem *)sender {
    
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



- (IBAction)record:(UIBarButtonItem *)sender {
    if (!audioRecorder.recording) {
        [audioRecorder record];
        recordButton.title = @"Stop";
        self.view.backgroundColor = [UIColor colorWithRed:0.352f green:0.202f blue:0.05f alpha:1.0f];
        NSLog(@"Record");
    } else {
        [audioRecorder stop];
        recordButton.title = @"Record";
        self.view.backgroundColor = [UIColor colorWithRed:0.09f green:0.282f blue:0.435f alpha:1.0f];
        
        //*** Setup AV Audio Player ***//
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
        audioPlayer.delegate = self;
        
        NSLog(@"Stop Record");
        
        //UIImage *test123 = [UIImage imageNamed:@"../images/play.png"];
        //UIImageView *test678 = [[UIImageView alloc] initWithImage:test123];
        
        //Call viewWaveformClass
        //UIImageView *waveFormView = [[WaveformImageView alloc] initWithUrl:audioRecorder.url];
        
        //scrollWaveform = [[UIScrollView alloc] initWithFrame:waveFormView.frame];
        
        //NSLog(@"%@",waveFormView.animationImages);
        //[scrollWaveform addSubview:waveFormView];
        //[self.view addSubview:waveFormView];
        
        
        [self floatExtract];
        
    }
}



- (IBAction)switchViewWaveform:(id)sender {
    viewWaveformViewController *viewWaveform = [[viewWaveformViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewWaveform animated:YES completion:NO];
}


- (IBAction)rewind:(UIBarButtonItem *)sender {
    
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    playPauseButton.title = @"Play";
    
    NSLog(@"Rewind");
}



//*** Extended Audio File Services ***//
- (int) floatExtract {
    
    //* (Float32) Audio Buffer: floatAudioBuffer
    //* (int)Size of Buffer: bufferSize
    
    // Open Extended Audio File
    CFURLRef inputFileURL = ((CFURLRef)CFBridgingRetain(soundFileURL));
    ExtAudioFileRef fileRef;
    CheckResult(ExtAudioFileOpenURL(inputFileURL, &fileRef), "ExtAudioFileOpenURL failed");
    
    
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
	
    
	// Log float values of AudioBufferList
	/*for( int y=0; y<convertedData.mNumberBuffers; y++ )
	{
		NSLog(@"buffer# %u", y);
		AudioBuffer audioBuffer = convertedData.mBuffers[y];
		bufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
		floatAudioBuffer = audioBuffer.mData;
		for( int i=0; i<bufferSize; i++ ) {
			Float32 currentSample = floatAudioBuffer[i];
			NSLog(@"currentSample: %f", currentSample);
		}
	}*/
    
    AudioBuffer audioBuffer = convertedData.mBuffers[0];
    bufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
    floatAudioBuffer = audioBuffer.mData;

    
    return 0;
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




//*** Write result buffer to Audio File ***//



//*** AVPlayer/Recorder Delegate Methods ***//

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing");
    playPauseButton.title = @"Play";
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording: (AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Finished Recording");
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occurred");
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
