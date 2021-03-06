//
//  FilterViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/25/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//
//  Recorded Input Buffer: (Float32) inputBuffer
//  Input Buffer Size: (int) inputBufferSize


#include <stdio.h>
#import "FilterViewController.h"
#import "EAFWrite.h"
#import "EAFRead.h"

#define SampleRate 44100.0

@interface FilterViewController ()

@end

@implementation FilterViewController

@synthesize playPauseResultButton, resultProgress, inputBuffer, inputBufferSize, channelCount;
@synthesize resultAudioPlayer, reverbParam, inURL;
@synthesize stairwell1Buffer, hall1Buffer, bathroom1Buffer, stairwell1Size, hall1Size, bathroom1Size;



/**************************************
 To use reverb slider, use:
 reverbParam.value
 
 To use the switch between functions to multiply with IR, use:
 if(reverbFunction.on) {
 Do e^x thingy;
 } else {
 Do square wave thingy;
 }
 ***************************************/


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
    
    
    // Setup outURL
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"reverb.caf"];
    outURL = [NSURL fileURLWithPath:soundFilePath];

    
    
    // Create URLs from IR Files
    //stairwell1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Stairwell1.caf", [[NSBundle mainBundle] resourcePath]]];
    //hall1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Hall1.caf", [[NSBundle mainBundle] resourcePath]]];
    //bathroom1 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Bathroom1.caf", [[NSBundle mainBundle] resourcePath]]];
    
    // Setup IR Buffer Sizes
    //stairwell1Duration =  3.430884;
    //hall1Duration = 0.768730;
    //bathroom1Duration = 0.9; // Must change
    
    // Setup ExtAudioFile Writer
    writer = [[EAFWrite alloc]init];
    //reader = [[EAFRead alloc]init];
    sqWaveFlag = 0;
    
    
    // Log Input Buffer
    /*for( int i=0; i<inputBufferSize; i++ ) {
     Float32 currentSample = inputBuffer[i];
     NSLog(@"currentSample: %f", currentSample);
     }*/
    
    
    /*** By default, play input ***/
    NSError *error;
    resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:inURL error:&error];
    resultAudioPlayer.delegate = self;
    NSLog(@"%@",error.description);
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//** Reverb Toggle **//
- (IBAction)reverbFunction:(UISwitch *)sender {
    
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
    
    if (resultAudioPlayer == nil) {
		NSLog(@"Error, Nil Audio Player");
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




//*** Write Out Buffer to CAF File ***//
- (IBAction)process:(UIBarButtonItem *)sender {
    
    [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
    
    outBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        outBuffer[i] = (float*)calloc(inputBufferSize, sizeof(float));
    
    
    // For debugging: Write input as CAF file
    outBuffer = &inputBuffer;
    
    [writer writeFloats:inputBufferSize fromArray:outBuffer];
    
    NSError *error;
	resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
    resultAudioPlayer.delegate = self;
    NSLog(@"%@",error.description);

}



//*** Reverb Implementations ***//

- (IBAction)applyStairwell:(UIButton *)sender {
    
    
    // Setup ExtAudioFile Reader
    //float duration = stairwell1Size;
    //IRBufferSize = duration*SampleRate;
    uint32_t IRBufferSize = stairwell1Size;
    
    /*[reader openFileForRead:stairwell1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];*/
    
    
    
    //perform convolution Reverb
    outBuffer = (float**) calloc(channelCount, sizeof(float));
    float *result;
    uint32_t outBufferSize;
    
    if(sqWaveFlag == 0)
    {
        
        //float *temp = &IRBuffer[0][0];
        float * temp = stairwell1Buffer;
        float *tt, *bk1, *env, *bk2;
    
        tt = (float*) malloc(IRBufferSize*sizeof(float));
        for(int i = 1; i<=IRBufferSize; i++)
        {
            tt[i] = i;                              //tt=1:1:length(bk);
        }
    
        int n = 6;
        float m = reverbParam.value;
        printf("\nm = %f\n",m);
    
        float delay = abs(m*IRBufferSize);              //delay = abs(m*length(bk));
        bk1 = (float*) malloc((int)delay*sizeof(float));
    
        for(int i = 0; i < (int)delay; i++)
        {
            bk1[i] = temp[i];                   //bk1 = bk(1:delay);
        }
    
        env = (float*) malloc(IRBufferSize*sizeof(float));
    
        for(int i = 0; i < (int)delay; i++)     //env = exp(-n*tt/delay);
        {                                       //env = env (1:delay);
            env[i] = exp(-n*tt[i]/delay);
        }
        bk2 = (float*) malloc((int)delay*sizeof(float));
        vDSP_vmul(bk1,1,env,1,bk2,1,(int)delay);    //bk2 = bk1.*env;
        bk2[0]=0;
    
        outBufferSize = inputBufferSize + (int)delay -1;
    
        result = (float*) malloc(outBufferSize*sizeof(float));
    
    
        for (int i = 0;i<channelCount;i++)
        {
            outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
        }
    
    

        if((int)delay > inputBufferSize)
        {
            result = myConv2(bk2, inputBuffer, (int)delay, inputBufferSize, outBufferSize);
        }else
        {
            result = myConv2(inputBuffer, bk2, inputBufferSize, (int)delay, outBufferSize);
        }
    }else
    {
        //float *temp = &IRBuffer[0][0];
        float *temp = stairwell1Buffer;
        float *bkSq, *sqEnv;
        
        sqEnv = (float*) malloc(IRBufferSize*sizeof(float));
        bkSq = (float*) calloc(IRBufferSize, sizeof(float));
        
        sqEnv = square(IRBufferSize,1);
        
        vDSP_vmul(temp,1,sqEnv,1,bkSq,1,IRBufferSize);
        
        
        outBufferSize = inputBufferSize + IRBufferSize - 1;
        
        result = (float*) malloc(outBufferSize*sizeof(float));
        
        
        for (int i = 0;i<channelCount;i++)
        {
            outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
        }
        
        
        
        if(IRBufferSize > inputBufferSize)
        {
            result = myConv2(bkSq, inputBuffer, IRBufferSize, inputBufferSize, outBufferSize);
        }else
        {
            result = myConv2(inputBuffer, bkSq, inputBufferSize, IRBufferSize, outBufferSize);
        }
        
        
        
    }

    outBuffer = &result;
    [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
    
    [writer writeFloats:outBufferSize fromArray:outBuffer];
    
    NSError *error;
	resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
    resultAudioPlayer.delegate = self;
    NSLog(@"%@",error.description);
    
    //free(outBuffer);
    //free(IRBuffer);
    free(result);

}


- (IBAction)applyHall:(UIButton *)sender {
    
    // Setup ExtAudioFile Reader
    //float duration = hall1Duration;
    //IRBufferSize = duration*SampleRate;
    uint32_t IRBufferSize = hall1Size;
    
    /*[reader openFileForRead:hall1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];*/
    
    //perform convolution Reverb
    outBuffer = (float**) calloc(channelCount, sizeof(float));
    float *result;
    uint32_t outBufferSize;
    
    if(sqWaveFlag == 0)
    {
        
        //float *temp = &IRBuffer[0][0];
        float *temp = hall1Buffer;
        float *tt, *bk1, *env, *bk2;
        
        tt = (float*) malloc(IRBufferSize*sizeof(float));
        for(int i = 1; i<=IRBufferSize; i++)
        {
            tt[i] = i;                              //tt=1:1:length(bk);
        }
        
        int n = 6;
        float m = reverbParam.value;
        printf("\nm = %f\n",m);
        
        float delay = abs(m*IRBufferSize);              //delay = abs(m*length(bk));
        bk1 = (float*) malloc((int)delay*sizeof(float));
        
        for(int i = 0; i < (int)delay; i++)
        {
            bk1[i] = temp[i];                   //bk1 = bk(1:delay);
        }
        
        env = (float*) malloc(IRBufferSize*sizeof(float));
        
        for(int i = 0; i < (int)delay; i++)     //env = exp(-n*tt/delay);
        {                                       //env = env (1:delay);
            env[i] = exp(-n*tt[i]/delay);
        }
        bk2 = (float*) malloc((int)delay*sizeof(float));
        vDSP_vmul(bk1,1,env,1,bk2,1,(int)delay);    //bk2 = bk1.*env;
        bk2[0]=0;
        
        outBufferSize = inputBufferSize + (int)delay -1;
        
        result = (float*) malloc(outBufferSize*sizeof(float));
        
        
        for (int i = 0;i<channelCount;i++)
        {
            outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
        }
        
        
        
        if((int)delay > inputBufferSize)
        {
            result = myConv2(bk2, inputBuffer, (int)delay, inputBufferSize, outBufferSize);
        }else
        {
            result = myConv2(inputBuffer, bk2, inputBufferSize, (int)delay, outBufferSize);
        }
    }else
    {
        //float *temp = &IRBuffer[0][0];
        float *temp = hall1Buffer;
        float *bkSq, *sqEnv;
        
        sqEnv = (float*) malloc(IRBufferSize*sizeof(float));
        bkSq = (float*) calloc(IRBufferSize, sizeof(float));
        
        sqEnv = square(IRBufferSize,1);
        
        vDSP_vmul(temp,1,sqEnv,1,bkSq,1,IRBufferSize);
        
        
        outBufferSize = inputBufferSize + IRBufferSize - 1;
        
        result = (float*) malloc(outBufferSize*sizeof(float));
        
        
        for (int i = 0;i<channelCount;i++)
        {
            outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
        }
        
        
        
        if(IRBufferSize > inputBufferSize)
        {
            result = myConv2(bkSq, inputBuffer, IRBufferSize, inputBufferSize, outBufferSize);
        }else
        {
            result = myConv2(inputBuffer, bkSq, inputBufferSize, IRBufferSize, outBufferSize);
        }
        
        
        
    }
    
    outBuffer = &result;
    [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
    
    [writer writeFloats:outBufferSize fromArray:outBuffer];
    
    NSError *error;
	resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
    resultAudioPlayer.delegate = self;
    NSLog(@"%@",error.description);
    
    //free(outBuffer);
    //free(IRBuffer);
    free(result);}


- (IBAction)applyBathroom:(UIButton *)sender {
    
    // Setup ExtAudioFile Reader
    //float duration = bathroom1Duration;
    //IRBufferSize = duration*SampleRate;
    uint32_t IRBufferSize = bathroom1Size;
   
    /*[reader openFileForRead:bathroom1 sr:SampleRate channels:1];
    
    IRBuffer = (float **)calloc(channelCount, sizeof(float*));
    for (int i = 0; i < channelCount; ++i)
        IRBuffer[i] = (float*)calloc(IRBufferSize, sizeof(float));
    
    [reader readFloatsConsecutive:IRBufferSize intoArray:IRBuffer];*/
    
     //perform convolution Reverb
     outBuffer = (float**) calloc(channelCount, sizeof(float));
     float *result;
     uint32_t outBufferSize;
     
     if(sqWaveFlag == 0)
     {
     
     //float *temp = &IRBuffer[0][0];
    float *temp = bathroom1Buffer;
     
     float *tt, *bk1, *env, *bk2;
     
     tt = (float*) malloc(IRBufferSize*sizeof(float));
     for(int i = 1; i<=IRBufferSize; i++)
     {
     tt[i] = i;                              //tt=1:1:length(bk);
     }
     
     int n = 6;
     float m = reverbParam.value;
     printf("\nm = %f\n",m);
     
     float delay = abs(m*IRBufferSize);              //delay = abs(m*length(bk));
     bk1 = (float*) malloc((int)delay*sizeof(float));
     
     for(int i = 0; i < (int)delay; i++)
     {
     bk1[i] = temp[i];                   //bk1 = bk(1:delay);
     }
     
     env = (float*) malloc(IRBufferSize*sizeof(float));
     
     for(int i = 0; i < (int)delay; i++)     //env = exp(-n*tt/delay);
     {                                       //env = env (1:delay);
     env[i] = exp(-n*tt[i]/delay);
     }
     bk2 = (float*) malloc((int)delay*sizeof(float));
     vDSP_vmul(bk1,1,env,1,bk2,1,(int)delay);    //bk2 = bk1.*env;
     bk2[0]=0;
     
     outBufferSize = inputBufferSize + (int)delay -1;
     
     result = (float*) malloc(outBufferSize*sizeof(float));
     
     
     for (int i = 0;i<channelCount;i++)
     {
     outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
     }
     
     
     
     if((int)delay > inputBufferSize)
     {
     result = myConv2(bk2, inputBuffer, (int)delay, inputBufferSize, outBufferSize);
     }else
     {
     result = myConv2(inputBuffer, bk2, inputBufferSize, (int)delay, outBufferSize);
     }
     }else
     {
     //float *temp = &IRBuffer[0][0];
    float *temp = bathroom1Buffer;
     
     float *bkSq, *sqEnv;
     
     sqEnv = (float*) malloc(IRBufferSize*sizeof(float));
     bkSq = (float*) calloc(IRBufferSize, sizeof(float));
     
     sqEnv = square(IRBufferSize,1);
     
     vDSP_vmul(temp,1,sqEnv,1,bkSq,1,IRBufferSize);
     
     
     outBufferSize = inputBufferSize + IRBufferSize - 1;
     
     result = (float*) malloc(outBufferSize*sizeof(float));
     
     
     for (int i = 0;i<channelCount;i++)
     {
     outBuffer[i] = (float*) calloc(outBufferSize, sizeof(float));
     }
     
     
     
     if(IRBufferSize > inputBufferSize)
     {
     result = myConv2(bkSq, inputBuffer, IRBufferSize, inputBufferSize, outBufferSize);
     }else
     {
     result = myConv2(inputBuffer, bkSq, inputBufferSize, IRBufferSize, outBufferSize);
     }
     
     
     
     }
     
     outBuffer = &result;
     [writer openFileForWrite:outURL sr:SampleRate channels:channelCount wordLength:16 type:kAudioFileCAFType];
     
     [writer writeFloats:outBufferSize fromArray:outBuffer];
     
     NSError *error;
     resultAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outURL error:&error];
     resultAudioPlayer.delegate = self;
     NSLog(@"%@",error.description);
     
     //free(outBuffer);
     //free(IRBuffer);
     free(result);

    

    
    

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
