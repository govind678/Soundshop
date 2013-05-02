//
//  dsp.c
//  Soundshop
//
//  Created by Ben Leedy on 4/9/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#include "dsp.h"

//#define DEBUG_PRINT


float* myConv(float *signal, float* filter, uint32_t lenSignal, uint32_t filterLength, uint32_t resultLength)
{
    float       *result;
    int32_t     signalStride, filterStride, resultStride;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    signalStride = resultStride = 1;
    filterStride = -1;
    
    printf("\nConvolution ( resultLength = %d, "
           "filterLength = %d )\n\n", resultLength, filterLength);
    
    result = (float*) malloc(resultLength * sizeof(float));
    
    if (result == NULL)
    {
        printf("\nmalloc failed to allocate memory for the convolution sample.\n");
        exit(0);
        
    }
    
    
    vDSP_conv(signal, signalStride, filter + filterLength - 1, filterStride, result, resultStride, resultLength, filterLength);
    
#ifdef DEBUG_PRINT
    uint32_t i;
    for(i=0;i<resultLength;i++)
        printf("\nresult[%i]: %f",i,result[i]);
#endif
    
    //scale ouput from -1 to 1;
    float max;
    vDSP_maxmgv(result,1,&max,resultLength);
    vDSP_vsdiv(result,1,&max,result,1,resultLength);
    
    
    return result;
    
    
}


//NOTE: may not handle zero padding yet. Be sure to use lenSignal = n

COMPLEX_SPLIT* myFFT( float *signal, uint32_t lenSignal, uint32_t log2n )
{
    COMPLEX_SPLIT* result;
    COMPLEX_SPLIT A;
    FFTSetup setupReal;
    uint32_t n, nOver2;
    int32_t stride;
    //float *obtainedReal;
    float scale;
    
    n = 1 << log2n;
    stride = 1;
    nOver2 = n/2;
    
    A.realp = (float*) malloc(nOver2 * sizeof(float));
    A.imagp = (float*) malloc(nOver2 * sizeof(float));
    //obtainedReal = (float*) malloc(n * sizeof(float));
    
    if (A.realp == NULL || A.imagp == NULL)
    {
        printf("\nmalloc failed to allocate memory for the real FFT section of the sample.\n");
        exit(0);
    }
    
    vDSP_ctoz((COMPLEX*)signal, 2, &A, 1, nOver2);
    setupReal = vDSP_create_fftsetup(log2n,FFT_RADIX2);

    if(setupReal == NULL)
    {
        printf("\nFFT_Setup failed to allocate enough memory for the reall FFT.\n");
        exit(0);
    }
    
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_FORWARD);
    
    scale = (float) 1.0/(2*n);
    vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2);
    vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2);
    
    result = &A;
    
    
    
    return result;
}


//NOTE: may not handle zero padding yet. Be sure to use lenSignal = n

float* myIFFT( COMPLEX_SPLIT *signal, uint32_t lenSignal, uint32_t log2n)
{
    COMPLEX_SPLIT A = *signal;
    FFTSetup setupReal;
    uint32_t n, nOver2;
    int32_t stride;
    float *obtainedReal;
    float scale;
    
    n = 1 << log2n;
    stride = 1;
    nOver2 = n/2;
    
    
    obtainedReal = (float*) malloc(n * sizeof(float));
    
    
    setupReal = vDSP_create_fftsetup(log2n,FFT_RADIX2);
    
    if(setupReal == NULL)
    {
        printf("\nFFT_Setup failed to allocate enough memory for the reall FFT.\n");
        exit(0);
    }
    
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_INVERSE);
    
    scale = (float) 1.0/(2*n);
    vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2);
    vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2);
    
    vDSP_ztoc(&A, 1, (COMPLEX*)obtainedReal, 2, nOver2);
    
    
    return obtainedReal;
    
}

float* phoneFx( float* signal, int32_t lenSignal)
{
    
     int32_t hpCoefsLength = 101;
     float hpCoefs[101] = {
         -0.1062572449,-0.004841230344,-0.004944163375,-0.005055206362,-0.005162511952,
         -0.005271412432,-0.005370895378,-0.005479875021,-0.005580984522, -0.00568908779,
         -0.005785096437,-0.005890527274,-0.005985334981,-0.006088918075,-0.006174746435,
         -0.006270361599,-0.006352534518,-0.006455784198,-0.006533319131,-0.006617377046,
         -0.006687714253,-0.006781756878,-0.006867933553,-0.006917490158,-0.006995375734,
         -0.007071773522,-0.007150833029,-0.007221587934,-0.007288081571,-0.007355116308,
         -0.007416829467,-0.007479513064,-0.007529947441,-0.007585166488,-0.007623333484,
         -0.00766819343,-0.007683063857,-0.007725903299,-0.007746439427,-0.007912777364,
         -0.007863470353,-0.007866290398, -0.00792547036,-0.007933524437,-0.007969116792,
         -0.007967676036,-0.007994743064, -0.00799550768,-0.008015736938,-0.008007841185,
         0.9919806123,-0.008007841185,-0.008015736938, -0.00799550768,-0.007994743064,
         -0.007967676036,-0.007969116792,-0.007933524437, -0.00792547036,-0.007866290398,
         -0.007863470353,-0.007912777364,-0.007746439427,-0.007725903299,-0.007683063857,
         -0.00766819343,-0.007623333484,-0.007585166488,-0.007529947441,-0.007479513064,
         -0.007416829467,-0.007355116308,-0.007288081571,-0.007221587934,-0.007150833029,
         -0.007071773522,-0.006995375734,-0.006917490158,-0.006867933553,-0.006781756878,
         -0.006687714253,-0.006617377046,-0.006533319131,-0.006455784198,-0.006352534518,
         -0.006270361599,-0.006174746435,-0.006088918075,-0.005985334981,-0.005890527274,
         -0.005785096437, -0.00568908779,-0.005580984522,-0.005479875021,-0.005370895378,
         -0.005271412432,-0.005162511952,-0.005055206362,-0.004944163375,-0.004841230344,
         -0.1062572449
     };
     
    
    int32_t lpCoefsLength = 101;
    float lpCoefs[101] = {
        -0.0009833249496, 0.003156685969, 0.001945509808, 0.001439259737,0.0007514060126,
        -0.0002327430266,-0.001311692526,-0.002152986359,-0.002423827071, -0.00192577939,
        -0.0006859450368, 0.001006351202, 0.002659232588, 0.003707234049, 0.003697291715,
        0.002456386806, 0.000200962415,-0.002481630538,-0.004766281694,-0.005834558513,
        -0.005146273412,-0.002659588587, 0.001076587127, 0.005022421014, 0.007912712172,
        0.00864110142, 0.006647816859, 0.002174526453,-0.003689836711,-0.009242708795,
        -0.0126232896, -0.01239191182,-0.008048924617,-0.0003414189559, 0.008785057813,
        0.01660447381,  0.02033981495,  0.01801230945, 0.009193312377, -0.00460323412,
        -0.02001515031, -0.03242938593, -0.03705336526, -0.03011006303,-0.009943567216,
        0.02231498808,  0.06270973384,   0.1050930992,   0.1423359662,   0.1678174883,
        0.176872164,   0.1678174883,   0.1423359662,   0.1050930992,  0.06270973384,
        0.02231498808,-0.009943567216, -0.03011006303, -0.03705336526, -0.03242938593,
        -0.02001515031, -0.00460323412, 0.009193312377,  0.01801230945,  0.02033981495,
        0.01660447381, 0.008785057813,-0.0003414189559,-0.008048924617, -0.01239191182,
        -0.0126232896,-0.009242708795,-0.003689836711, 0.002174526453, 0.006647816859,
        0.00864110142, 0.007912712172, 0.005022421014, 0.001076587127,-0.002659588587,
        -0.005146273412,-0.005834558513,-0.004766281694,-0.002481630538, 0.000200962415,
        0.002456386806, 0.003697291715, 0.003707234049, 0.002659232588, 0.001006351202,
        -0.0006859450368, -0.00192577939,-0.002423827071,-0.002152986359,-0.001311692526,
        -0.0002327430266,0.0007514060126, 0.001439259737, 0.001945509808, 0.003156685969,
        -0.0009833249496
    };
    
    
    float *result, *temp;
    int32_t resultLen = lenSignal+200;
    
    
    result = (float*) malloc(resultLen*sizeof(float));
    //resultTemp = (float*) malloc(resultLen*sizeof(float));
    temp = (float*) malloc((lenSignal+100)*sizeof(float));
    
    float *lpPtr = &lpCoefs[0];
    float *hpPtr = &hpCoefs[0];
    
    temp = myConv2(signal, lpPtr, lenSignal, lpCoefsLength, resultLen-100); //lowpass
    result = myConv2(temp, hpPtr, lenSignal, hpCoefsLength, resultLen); //highpass
    
    
    int i;
    float whiteNoise[resultLen];
    float amount =  0.01;
    for(i=0;i<resultLen;i++)
    {
        whiteNoise[i] = amount*rand();
        whiteNoise[i] = whiteNoise[i]/RAND_MAX;
        printf("\nwhiteNoise[%i] = %f",i,whiteNoise[i]);
    }
    vDSP_vadd(result, 1, whiteNoise, 1, result, 1, resultLen);
    
    
    return result;
    
}



float* bqFilter(float *signal, int32_t lenSignal, float *coefs)
{
    
    // first 3 coefficients are 'b' which determine zeros (numerator)
    // and last 2 coeffs are 'a' which determine poles
    
    float *result;
    
    result = (float*)malloc(lenSignal*sizeof(float));
    
    //initialize first two elements
    result[0] = 0;
    result[1] = 0;
    
    
    vDSP_deq22(signal, 1, coefs, result, 1, lenSignal-2);
    return result;
    
    
}

float* cryBaby(float *signal, int32_t lenSignal, float pedalValue, float gainDM)
{
    float *result;
    result = (float*) malloc(lenSignal*sizeof(float));
    
    float PI = 3.14159;
    float g = 0.1*(pow((double)gainDM, (double)pedalValue));
    float fr = 450*pow(2, 2.3*pedalValue);
    float Q = pow(2,2*(1-pedalValue)+1);
    
    float frn = fr/44100;
    float R = 1-PI*frn/Q;
    float theta = 2*PI*frn;
    float a[5];
    a[0] = 1;
    a[1] = 0;
    a[2] = 0;
    a[3] = -2.0*R*cos(theta);
    a[4] = R*R;
    result = bqFilter(signal, lenSignal, a);
    vDSP_vsmul(result, 1, &g, result, 1, lenSignal);
    return result;
    
}

float* myConv2(float *signal, float *filter, int lenSignal, int lenFilter, int lenResult)
{
    int i,j;
    float *y;
    
#ifdef DEBUG_PRINT
    for(int i = 0; i < lenSignal; i++)
        printf("\nsignal[%i] = %f",i,signal[i]);
    
    for(int i = 0; i < lenFilter; i++)
        printf("\nfilter[%i] = %f",i,filter[i]);
#endif
    
    y = (float*) malloc(lenResult*sizeof(float));
    
    for ( i = 0; i < lenResult; i++ )
    {
        y[i] = 0;                       // set to zero before sum
        for ( j = 0; j < lenFilter; j++ )
        {
            
            if(i >= lenSignal )
            {
                if(j+(i-lenSignal) < lenFilter)
                {
                    y[i] += signal[lenSignal-1-j]*filter[j+(i-lenSignal+1)];
                    
                }
                
            }else if(i-j >= 0)
            {
                y[i] += signal[i - j] * filter[j];    // convolve: multiply and accumulate
                
            }
        }
    }
    
    
    float max;
    vDSP_maxmgv(y,1,&max,lenResult);
    vDSP_vsdiv(y,1,&max,y,1,lenResult);
    
#ifdef DEBUG_PRINT
    for(int i = 0; i < lenResult; i++)
        printf("\ny[%i] = %.99g",i,y[i]);
#endif
    
    
    
    return y;
  
    
    
}

float* vinyl(float*signal, uint32_t lenSignal)
{
    int curInd = 0;
    unsigned long newInd;
    float amp;
    printf("\nRAND_MAX = %i",RAND_MAX);
    
    //add clicks/pops
    while(curInd < lenSignal-5)
    {
        newInd = rand() % 8000;
        amp = 0.3*rand();
        amp /= RAND_MAX;
        curInd = curInd + newInd;
        for(int i = 0; i < 5; i++)
        {
            if(curInd < lenSignal-5)
                signal[curInd+i] = amp;
        }
    }

    float whiteNoise[lenSignal];
    float amount =  0.01;
    for(int i=0;i<lenSignal;i++)
    {
        whiteNoise[i] = amount*rand();
        whiteNoise[i] = whiteNoise[i]/RAND_MAX;
        printf("\nwhiteNoise[%i] = %f",i,whiteNoise[i]);
    }
    vDSP_vadd(signal, 1, whiteNoise, 1, signal, 1, lenSignal);

    
    return signal;
    
}

float* square(int lenSignal, float f)
{       //frequency in Hz
    float fs = 44100;   //sampling rate
    float dc = 10;  //duty cycle
    float *result;
    result = (float*)calloc(lenSignal, sizeof(float));
    float temp = fs/dc;
    
    for (int i = 0; i < (int)(lenSignal/(44100/f)); i++)
    {
        printf("\n%i", i);
        for(int j = 0;j<temp;j++)
        {
            if(i*(int)fs+j <= lenSignal)
                result[i*(int)fs+j] = 1;
        }
        
        
    }
#ifdef DEBUG_PRINT
    for(int i = 0; i < lenSignal; i++)
    {
        printf("\nresult[%i] = %f",i,result[i]);
        
    }
#endif

    return result;
    
    
}




