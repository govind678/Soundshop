//
//  dsp.c
//  Soundshop
//
//  Created by Ben Leedy on 4/9/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#include "dsp.h"


float* myConv(float *signal, float* filter, uint32_t lenSignal, uint32_t filterLength, uint32_t resultLength)
{
    float       *result;
    int32_t     signalStride, filterStride, resultStride;
    
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
    
    uint32_t i;
    for(i=0;i<resultLength;i++)
        printf("\n%f",result[i]);
    
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
