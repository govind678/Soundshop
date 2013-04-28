//
//  viewWaveformViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "viewWaveformViewController.h"


@interface viewWaveformViewController ()

@end

@implementation viewWaveformViewController

@synthesize playOutputButton;


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
    
    //stairwell1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Stairwell1.caf", [[NSBundle mainBundle] resourcePath]]];
    //hall1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Hall1.caf", [[NSBundle mainBundle] resourcePath]]];

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


//--- Switch view to Home Screen ---//
- (IBAction)switchHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}


//--- Apply Reverb to Recorded File ---//
- (IBAction)applyReverb:(UIButton *)sender {
    
    //Float32 floatIRBuffer = [self floatExtract:stairwell1];
    
    //NSLog(@"IR Buffer: %f",floatIRBuffer);
    
}


//--- Apply EQ to Recorded File ---//
- (IBAction)applyEQ:(UIButton *)sender {
}


//--- Play Result ---//
- (IBAction)playOutput:(UIBarButtonItem *)sender {
}


//--- Pause/Stop Result ---//
- (IBAction)rewindOutput:(UIBarButtonItem *)sender {

//*** Apply Reverb Effect ***//
- (IBAction)applyReverb:(UIButton *)sender {
    
    // Convert IR to Float32 array (select appropriate NSURL)
    Float32 *floatIRBuffer = [self floatExtract:hall1];
    
    /*
    for( int i=0; i<IRBufferSize; i++ ) {
        Float32 currentSample = floatIRBuffer[i];
        NSLog(@"currentSample: %f", currentSample);
    }
    */
    int32_t resultSize;

    float* result;
    
    if(IRBufferSize > inputBufferSize)
    {
        resultSize = IRBufferSize;
    }else
    {
        resultSize = inputBufferSize;
    }
    
    printf("\nIRBufferSize = %i",IRBufferSize);
    printf("\ninputBufferSize = %i", inputBufferSize);
    result = malloc(sizeof(float)*resultSize);
    
    result = myConv(inputBuffer, floatIRBuffer, inputBufferSize, IRBufferSize, resultSize);
    
    int i;
    for(i=0;i<inputBufferSize;i++)
    {
        printf("\ninputBuffer[%i] = %f",i,inputBuffer[i]);
    }
    
>>>>>>> c36c8d01d2c6b3bac5042c35d888a2501de40a7d:Soundshop/FilterViewController.m
}






//*** Extended Audio File Services ***//
- (Float32)floatExtract: (NSURL *)IRFile {
    
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
	
    
    AudioBuffer audioBuffer = convertedData.mBuffers[0];
    currentBufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
    Float32 *floatBuffer = audioBuffer.mData;
    
    
    // Log float values of AudioBufferList
	/*for (int y=0; y<convertedData.mNumberBuffers; y++ )
    {
        NSLog(@"buffer# %u", y);
        AudioBuffer audioBuffer = convertedData.mBuffers[y];
        currentBufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
        floatBuffer = audioBuffer.mData;
        for( int i=0; i<currentBufferSize; i++ ) {
            Float32 currentSample = floatBuffer[i];
            NSLog(@"currentSample: %f", currentSample);
        }
    }*/
    
    return *(floatBuffer);
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


@end
