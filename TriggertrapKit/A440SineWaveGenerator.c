/*
 * Copyright (c) 2010 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "A440SineWaveGenerator.h"
#include <math.h>

const Float64 SAMPLE_RATE = 44100.0;

void A440SineWaveGeneratorInitWithFrequency(A440SineWaveGenerator *self, double frequency) {
    // Given:
    //   frequency in cycles per second
    //   2 * PI radians per sine wave cycle
    //   sample rate in samples per second
    //
    // Then:
    //   cycles     radians     seconds     radians
    //   ------  *  -------  *  -------  =  -------
    //   second      cycle      sample      sample
    
    self->currentPhase = 0.0;
    self->phaseIncrement = frequency * 2 * M_PI / SAMPLE_RATE;
}

int16_t A440SineWaveGeneratorNextSample(A440SineWaveGenerator *self) {
    int16_t sample = INT16_MAX * sinf(self->currentPhase);
    
    self->currentPhase += self->phaseIncrement;
    
    // Keep the value between 0 and 2 * M_PI
    while (self->currentPhase > 2 * M_PI) {
        self->currentPhase -= 2 * M_PI;
    }
    
    return sample;
}
