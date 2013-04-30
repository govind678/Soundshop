//
//  dsp.h
//  Soundshop
//
//  Created by Ben Leedy on 4/10/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#ifndef Soundshop_dsp_h
#define Soundshop_dsp_h

#include <stdio.h>
#include <stdlib.h>
#include <Accelerate/Accelerate.h>
#include <stdint.h>
#include <math.h>



float* myConv(float *signal, float* filter, uint32_t lenSignal, uint32_t filterLength, uint32_t resultLength);
float* myConv2(float *signal, float *filter, int lenSignal, int lenFilter, int lenResult);
COMPLEX_SPLIT* myFFT( float *signal, uint32_t lenSignal, uint32_t log2n );
float* myIFFT( COMPLEX_SPLIT *signal, uint32_t lenSignal, uint32_t log2n);
float* phoneFx( float* signal, int32_t lenSignal);
float* cryBaby(float *signal, int32_t lenSignal, float pedalValue, float gainDM);
float* bqFilter(float *signal, int32_t lenSignal, float *coefs);

#endif
