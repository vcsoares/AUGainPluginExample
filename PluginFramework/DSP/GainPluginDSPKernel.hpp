//
//  GainPluginDSPKernel.hpp
//  GainPluginFramework
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

#ifndef GainPluginDSPKernel_hpp
#define GainPluginDSPKernel_hpp

#import "DSPKernel.hpp"

// MARK: - INTERNAL PARAMETER ENUM

enum {
    pGain = 0,
};

/*
 GainPluginDSPKernel
 Performs simple copying of the input signal to the output.
 As a non-ObjC class, this is safe to use from render thread.
 */
class GainPluginDSPKernel : public DSPKernel {
    // MARK: - Member Variables

private:
    int chanCount = 0;
    float sampleRate = 44100.0;
    bool bypassed = false;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
    
public:
    float fGain;
    
    // MARK: - Member Functions

    GainPluginDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        chanCount = channelCount;
        sampleRate = float(inSampleRate);
    }

    void reset() {
    }

    bool isBypassed() {
        return bypassed;
    }

    void setBypass(bool shouldBypass) {
        bypassed = shouldBypass;
    }

    // MARK: - PARAMETER ACCESSORS
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case pGain:
                fGain = value;
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case pGain:
                // Return the goal. It is not thread safe to return the ramping value.
                return fGain;
            default: return 0.f;
        }
    }
    
    // MARK: - DSP CODE
    
    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        if (bypassed) {
            // Pass the samples through
            for (int channel = 0; channel < chanCount; ++channel) {
                if (inBufferListPtr->mBuffers[channel].mData ==  outBufferListPtr->mBuffers[channel].mData) {
                    continue;
                }
                
                for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                    const int frameOffset = int(frameIndex + bufferOffset);
                    const float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                    float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                    *out = *in;
                }
            }
            return;
        }
        
        // Perform per sample dsp on the incoming *in before asigning it to *out
        for (int channel = 0; channel < chanCount; ++channel) {
        
            // Get pointer to immutable input buffer and mutable output buffer
            const float* in = (float*)inBufferListPtr->mBuffers[channel].mData;
            float* out = (float*)outBufferListPtr->mBuffers[channel].mData;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                const int frameOffset = int(frameIndex + bufferOffset);
                
                // MARK: - Do your sample by sample dsp here...
                
                printf("%f\n", getParameter(pGain));
                out[frameOffset] = in[frameOffset] * getParameter(pGain);
            }
        }
    }
};

#endif /* GainPluginDSPKernel_hpp */
