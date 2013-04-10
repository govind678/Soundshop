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

float* myConv(float *signal, float* filter, uint32_t lenSignal, uint32_t filterLength, uint32_t resultLength);


#endif
