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
    
    return(result);
    
    
    
}
