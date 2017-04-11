^{
    <#code#>
}/*
 
     File: SpectralEQ.cpp
 Abstract: Audio Unit class implementation.
  Version: 1.0.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
*/

#include "SpectralEQ.h"
#include <iostream>

#define kMaxBlockSize 16384

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// COMPONENT_ENTRY(SpectralEQ) deprecated on MacOS X 10.7 see TN2276 

AUDIOCOMPONENT_ENTRY(AUBaseFactory, SpectralEQ)


OSStatus renderInput(void *inRefCon,
                     AudioUnitRenderActionFlags *ioActionFlags,
                     const AudioTimeStamp *inTimeStamp,
                     UInt32 inBusNumber,
                     UInt32 inNumberFrames,
                     AudioBufferList *ioData)
{
    
    
    float *outA = (float*)ioData->mBuffers[0].mData;
    float *outB = (float*)ioData->mBuffers[1].mData;
    
    for(unsigned i = 0; i < inNumberFrames; i++)
    {
        float tone = (float)drand48() * 2.0 - 1.0;;
        outA[i] = tone;
        outB[i] = tone;
    }
    
    return noErr;
}

void SpectralEQ::initializeGraph()
{
    mResult = noErr;
    
    mResult = NewAUGraph(&mGraph);
    
    // Store Output Description and add the node
    mCompDesc = {kAudioUnitType_Output, kAudioUnitSubType_GenericOutput, kAudioUnitManufacturer_Apple, 0, 0};
    
    mResult = AUGraphAddNode(mGraph, &mCompDesc, &outputNode);
    
    if (mResult)
    {
        printf("AUGraphAddNode 1 result %lu %4.4s\n", (unsigned long)mResult, (char*)&mResult);
        return;
    }
    
    // Route incoming audio to the output
    mResult = AUGraphConnectNodeInput(mGraph, outputNode, 1, outputNode, 0);
    
    if (mResult)
    {
        printf("AUGraphAddNode result %d\n", mResult);
        return;
    }
    
    // Open The Graph
    mResult = AUGraphOpen(mGraph);
    
    if (mResult)
    {
        printf("AUGraphOpen result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    mResult = AUGraphNodeInfo(mGraph, outputNode, NULL, &output);
    
    if (mResult) {
        printf("AUGraphNodeInfo result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    UInt32 size;
    
    AURenderCallbackStruct renderObj;
    renderObj.inputProc = &renderInput;
    
    
    // White Noise Testing
    mResult = AudioUnitSetProperty(input,
     kAudioUnitProperty_SetRenderCallback,
     kAudioUnitScope_Input,
     0,
     &renderObj,
     sizeof(renderObj) );
    
    
    size = sizeof(mStreamDesc);
    
    
    UInt32 enableIO = 1;
    
    mResult = AudioUnitSetProperty(output,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  1,
                                  &enableIO,
                                  sizeof(enableIO) );
    if (mResult)
    {
        printf("EnableIO result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    mResult = AudioUnitSetProperty(output,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  0,
                                  &enableIO,
                                  sizeof(enableIO) );
    if (mResult)
    {
        printf("EnableIO result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    mResult = AudioUnitGetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  1,
                                  &mStreamDesc,
                                  &size );
    
    if (mResult)
    {
        printf("StreamFormat result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    mResult = AudioUnitGetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &mStreamDesc,
                                  &size );
    
    if (mResult)
    {
        printf("StreamFormat result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
    
    mResult = AUGraphInitialize(mGraph);
    
    if (mResult)
    {
        printf("AUGraphInitialize result %d\n", mResult);
        return;
    }
    
    CAShow(mGraph);
    
    //mResult = AUGraphStart(mGraph);
    
    
    if (mResult)
    {
        printf("AUGraphStart result %u %4.4s\n", (unsigned int)mResult, (char*)&mResult);
        return;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::SpectralEQ
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SpectralEQ::SpectralEQ(AudioUnit component)	: AUEffectBase(component)
{
	CreateElements();
	Globals()->UseIndexedParameters(kNumberOfParameters);
	SetParameter(kParam_One, kDefaultValue_ParamOne );
	
}

OSStatus SpectralEQ::Initialize()
{
    OSStatus result = AUEffectBase::Initialize();
    
    if(result == noErr)
    {
        mDSP_FFT.Allocate(GetNumberOfChannels(), kMaxBlockSize);
        mComputedMagnitudes.alloc(kMaxBlockSize >> 1);
        
        mInfos.mNumBins = 0;
        mInfos.mNumChannels = GetNumberOfChannels();
        mInfos.mSamplingRate = GetSampleRate();
    }
    
    initializeGraph();
    
    return result;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::GetParameterValueStrings
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OSStatus			SpectralEQ::GetParameterValueStrings(AudioUnitScope		inScope,
                                                                AudioUnitParameterID	inParameterID,
                                                                CFArrayRef *		outStrings)
{
        
    return kAudioUnitErr_InvalidProperty;
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::GetParameterInfo
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OSStatus			SpectralEQ::GetParameterInfo(AudioUnitScope		inScope,
                                                        AudioUnitParameterID	inParameterID,
                                                        AudioUnitParameterInfo	&outParameterInfo )
{
	OSStatus result = noErr;

	outParameterInfo.flags = 	kAudioUnitParameterFlag_IsWritable + kAudioUnitParameterFlag_IsReadable;
    
    if (inScope == kAudioUnitScope_Global) {
        switch(inParameterID)
        {
            case kParam_One:
                AUBase::FillInParameterName (outParameterInfo, kParameterOneName, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
                outParameterInfo.minValue = 0.0;
                outParameterInfo.maxValue = 1;
                outParameterInfo.defaultValue = kDefaultValue_ParamOne;
                break;
            default:
                result = kAudioUnitErr_InvalidParameter;
                break;
            }
	} else {
        result = kAudioUnitErr_InvalidParameter;
    }
    


	return result;
}


// START COCOA UI::
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::GetPropertyInfo
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OSStatus			SpectralEQ::GetPropertyInfo (AudioUnitPropertyID	inID,
                                                        AudioUnitScope		inScope,
                                                        AudioUnitElement	inElement,
                                                        UInt32 &		outDataSize,
                                                        Boolean &		outWritable)
{
	if (inScope == kAudioUnitScope_Global) 
	{
		switch (inID) 
		{
			case kAudioUnitProperty_CocoaUI:
				outWritable = false;
				outDataSize = sizeof (AudioUnitCocoaViewInfo);
				return noErr;
            case kAudioUnitProperty_SpectrumGraphInfo:
                outWritable = false;
                outDataSize = sizeof(SpectrumGraphInfo);
                return noErr;
            case kAudioUnitProperty_SpectrumGraphData:
                outWritable = false;
                outDataSize = mInfos.mNumBins * sizeof(Float32);
                return noErr;
					
		}
	}

	return AUEffectBase::GetPropertyInfo (inID, inScope, inElement, outDataSize, outWritable);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::GetProperty
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OSStatus			SpectralEQ::GetProperty(	AudioUnitPropertyID inID,
															AudioUnitScope 		inScope,
															AudioUnitElement 	inElement,
															void *				outData )
{
	if (inScope == kAudioUnitScope_Global) 
	{
		switch (inID) 
		{
			case kAudioUnitProperty_CocoaUI:
			{
				// Look for a resource in the main bundle by name and type.
				CFBundleRef bundle = CFBundleGetBundleWithIdentifier( CFSTR("com.SPEQ.audiounit.SpectralEQ") );
				
				if (bundle == NULL) return fnfErr;
                
				CFURLRef bundleURL = CFBundleCopyResourceURL( bundle, 
                    CFSTR("SpectralEQ_CocoaViewFactory"), 
                    CFSTR("bundle"), 
                    NULL);
                
                if (bundleURL == NULL) return fnfErr;

				AudioUnitCocoaViewInfo cocoaInfo;
				cocoaInfo.mCocoaAUViewBundleLocation = bundleURL;
				cocoaInfo.mCocoaAUViewClass[0] = CFStringCreateWithCString(NULL, "SpectralEQ_CocoaViewFactory", kCFStringEncodingUTF8);
				
				*((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;
				
				return noErr;
            }
            // This property gives infos about the computed magnitudes
            case kAudioUnitProperty_SpectrumGraphInfo:
            {
                SpectrumGraphInfo* g = (SpectrumGraphInfo*) outData;
                
                g->mNumBins = mInfos.mNumBins;
                g->mSamplingRate = mInfos.mSamplingRate;
                g->mNumChannels = mInfos.mNumChannels;
                
                return noErr;
            }
                // This property sends magnitudes data as Float32
            case kAudioUnitProperty_SpectrumGraphData:
            {
                Float32* mData = (Float32*) outData;
                
                if(mInfos.mNumBins > 0)
                {
                    memcpy(mData, mComputedMagnitudes(), mInfos.mNumBins * sizeof(Float32));
                }
            }
		}
	}

	return AUEffectBase::GetProperty (inID, inScope, inElement, outData);
}

// END COCOA UI

#pragma mark ____SpectralEQEffectKernel


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::SpectralEQKernel::Reset()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void		SpectralEQ::SpectralEQKernel::Reset()
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	SpectralEQ::SpectralEQKernel::Process
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void SpectralEQ::SpectralEQKernel::Process(	const Float32 	*inSourceP,
                                                    Float32		 	*inDestP,
                                                    UInt32 			inFramesToProcess,
                                                    UInt32			inNumChannels, // for version 2 AudioUnits inNumChannels is always 1
                                                    bool			&ioSilence )
{

	//This code will pass-thru the audio data.
	//This is where you want to process data to produce an effect.
    AudioBuffer newBuffer;
    AudioBufferList newList;
    newList.mNumberBuffers = 1;
    newList.mBuffers[0].mNumberChannels = 1;
    newList.mBuffers[0].mDataByteSize = inFramesToProcess * (sizeof(Float32));
    newList.mBuffers[0].mData = inDestP;
    
    //AudioUnitRender(output, 0, const AudioTimeStamp *inTimeStamp, <#UInt32 inOutputBusNumber#>, <#UInt32 inNumberFrames#>, <#AudioBufferList *ioData#>)
	
	UInt32 nSampleFrames = inFramesToProcess;
	const Float32 *sourceP = inSourceP;
	Float32 *destP = inDestP;
    Float32 gain = GetParameter( kParam_One );
		
	while (nSampleFrames-- > 0) {
		Float32 inputSample = *sourceP;
		
		//The current (version 2) AudioUnit specification *requires* 
	    //non-interleaved format for all inputs and outputs. Therefore inNumChannels is always 1
		
		sourceP += inNumChannels;	// advance to next frame (e.g. if stereo, we're advancing 2 samples);
									// we're only processing one of an arbitrary number of interleaved channels

			// here's where you do your DSP work
                Float32 outputSample = inputSample * gain;
		
		*destP = outputSample;
		destP += inNumChannels;
	}
}

OSStatus SpectralEQ::Render(AudioUnitRenderActionFlags & ioActionFlags,
                           const AudioTimeStamp & inTimeStamp,
                           UInt32 inFramesToProcess )
{
    
    UInt32 actionFlags = 0;
    OSStatus err = PullInput(0, actionFlags, inTimeStamp, inFramesToProcess);
    
    //Float32 gain = GetParameter(kParam_One);
    
    if(err)
        return err;
    
    GetOutput(0)->PrepareBuffer(inFramesToProcess);
    
    AudioBufferList& inputBuffer = GetInput(0)->GetBufferList();
    
    //std::cout << *(float *)inputBuffer.mBuffers[0].mData << std::endl;
    
    mDSP_FFT.CopyInputToRingBuffer(inFramesToProcess, &inputBuffer);
    
    // TEMP
    UInt32 currentBlockSize = 1024;
    
    // TEMP
    DSP_FFT::Window currentWindow = DSP_FFT::Window::Blackman;
    
    
    if(mDSP_FFT.ApplyFFT(currentBlockSize, currentWindow))
    {
        mInfos.mNumBins = currentBlockSize >> 1;
        
        // TEMP
        UInt32 channelSelect = 1;
        
        if(mDSP_FFT.GetMagnitudes(mComputedMagnitudes, currentWindow, channelSelect))
        {
            PropertyChanged(kAudioUnitProperty_SpectrumGraphData, kAudioUnitScope_Global, 0);
        }
    }
    
    return AUEffectBase::Render(ioActionFlags, inTimeStamp, inFramesToProcess);
    
}

