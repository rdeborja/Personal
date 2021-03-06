/*****************************************************************************/
/*!
 \file   PS_Core.mm
 \author Deepak Chennakkadan
 \par    email: deepak.chennakkadan\@digipen.edu
 \par    DigiPen login: deepak.chennakkadan
 \par    Course: MUS470
 \par    Project: PedalStack
 \date   12/13/2016
 \brief
 This file contains the implementation for CoreAudio and managing the audio 
 graph
 */
/*****************************************************************************/

#define TEST 0

#import "PS_Core.h"
#include <iostream>

@implementation PS_Core

- (void) awakeFromNib
{
    [self initializeGraph];
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Dynamically allocates and creates a new effect
 
 \param effect
 (Type of effect)
 
 \param graph
 (Audio Unit Graph)
 
 \param outNode
 (Output Node)
 
 \return
 Does not return anything
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (void) CreateNewEffect: (UInt32) effect arg2: (AUGraph) graph arg3: (AUNode) outNode
{
    PS_Effects *NewEffect = new PS_Effects(effect, mGraph, outNode, mStreamDesc);
    mEffects.push_back(NewEffect);
    mEffectIDs.push_back(effect);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Adds the effect to the graph and handles node conenctions
 
 \param effect
 (Type of effect)
 
 \return
 Does not return anything
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (void) AddNewEffect: (UInt32) effect
{
    [self CreateNewEffect:effect arg2:mGraph arg3:outputNode];
    
    // Stop the graph
    AUGraphStop(mGraph);
    
    // Disconnect the output node
    AUGraphDisconnectNodeInput(mGraph, outputNode, 0);
    
    if(mEffects.size() == 1)
    {
        // If only one effect is in the signal chain
        mEffects[mEffects.size() - 1]->ConnectEffectIO(outputNode, mEffects[mEffects.size() - 1]->GetEffectNode(), 1);
    }
    else
    {
        // If more than one effects are present in the signal chain
        mEffects[mEffects.size() - 2]->ConnectEffectIO(mEffects[mEffects.size() - 2]->GetEffectNode(), mEffects[mEffects.size() - 1]->GetEffectNode());
        mEffects[mEffects.size() - 2]->GetEffectInfo();
        mEffects[mEffects.size() - 2]->SetStreamDescription(output);
    }
    
    // Route the effect to the output
    mEffects[mEffects.size() - 1]->ConnectEffectIO(mEffects[mEffects.size() - 1]->GetEffectNode(), outputNode);
    
    mEffects[mEffects.size() - 1]->GetEffectInfo();
    mEffects[mEffects.size() - 1]->SetStreamDescription(output);
    
    // Start the graph
    AUGraphStart(mGraph);
    
    // Print out signal chain
    CAShow(mGraph);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Removes the last effect from the graph and handles node conenctions
 
 \return
 Does not return anything
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (void) RemoveEffect
{
    // Stop the graph
    AUGraphStop(mGraph);
    
    // Disconnect the output node
    AUGraphDisconnectNodeInput(mGraph, outputNode, 0);
    
    // Disconnect the last node
    mEffects[mEffects.size() - 1]->DisconnectEffectIO();
    
    // Remove effects from the containers
    mEffects.pop_back();
    mEffectIDs.pop_back();
    
    if(mEffects.size() != 0)
    {
        // Route the effect to the output
        mEffects[mEffects.size() - 1]->ConnectEffectIO(mEffects[mEffects.size() - 1]->GetEffectNode(), outputNode);
        mEffects[mEffects.size() - 1]->GetEffectInfo();
        mEffects[mEffects.size() - 1]->SetStreamDescription(output);
    }
    else
    {
        result = AUGraphConnectNodeInput(mGraph, outputNode, 1, outputNode, 0);
        
        if (result)
        {
            printf("AUGraphAddNode result %d\n", result);
            return;
        }
    }
    
    // Start the graph
    AUGraphStart(mGraph);
    
    // Print out signal chain
    //CAShow(mGraph);
}


- (void) SwapEffect: (UInt32) effect arg2: (unsigned) index
{
    // Stop the graph
    AUGraphStop(mGraph);
    
    PS_Effects *NewEffect = new PS_Effects(effect, mGraph, outputNode, mStreamDesc);
    
    mEffects[index]->DisconnectEffectIO();
    
    mEffects.push_back(NewEffect);
    std::replace(mEffects.begin(), mEffects.end(), mEffects[index], mEffects[mEffects.size() - 1]);
    mEffects.pop_back();
    
    mEffectIDs.push_back(effect);
    std::replace(mEffectIDs.begin(), mEffectIDs.end(), mEffectIDs[index], mEffectIDs[mEffectIDs.size() - 1]);
    mEffectIDs.pop_back();
    
    // If its the last pedal
    if(index == mEffects.size() - 1 && index != 0)
    {
        // Connect previous pedal to current
        mEffects[index]->ConnectEffectIO(mEffects[index - 1]->GetEffectNode(), mEffects[index]->GetEffectNode());
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
        
        // Connect current pedal to output
        mEffects[index]->ConnectEffectIO(mEffects[mEffects.size() - 1]->GetEffectNode(), outputNode);
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
    }
    // If its the first pedal and the only pedal
    else if(index == 0 && mEffects.size() == 1)
    {
        // Disconnect Output node
        AUGraphDisconnectNodeInput(mGraph, outputNode, 0);
        
        // Connect input to current pedal
        mEffects[index]->ConnectEffectIO(outputNode, mEffects[index]->GetEffectNode(), 1);
        
        // Conenct current pedal to output
        mEffects[index]->ConnectEffectIO(mEffects[index]->GetEffectNode(), outputNode);
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
    }
    // If its the first pedal and there are more pedals
    else if(index == 0 && mEffects.size() > 1)
    {
        // Disconnect Output node
        AUGraphDisconnectNodeInput(mGraph, outputNode, 0);
        
        // Conect input to current pedal
        mEffects[index]->ConnectEffectIO(outputNode, mEffects[index]->GetEffectNode(), 1);
        
        // Conenct current pedal to next pedal
        mEffects[index]->ConnectEffectIO(mEffects[index]->GetEffectNode(), mEffects[index + 1]->GetEffectNode());
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
        
        // Connect last pedal to the output
        mEffects[index]->ConnectEffectIO(mEffects[mEffects.size() - 1]->GetEffectNode(), outputNode);
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
    }
    // If its any other pedal in the signal chain
    else
    {
        // Connect previous pedal to current pedal
        mEffects[index]->ConnectEffectIO(mEffects[index - 1]->GetEffectNode(), mEffects[index]->GetEffectNode());
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
        
        // Conenct current pedal to the next pedal
        mEffects[index]->ConnectEffectIO(mEffects[index]->GetEffectNode(), mEffects[index + 1]->GetEffectNode());
        mEffects[index]->GetEffectInfo();
        mEffects[index]->SetStreamDescription(output);
    }
    
    // Start the graph
    AUGraphStart(mGraph);
    
    // Print out signal chain
    CAShow(mGraph);
    
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Gets an effect corresponding to the ID
 
 \param id
 (Effect ID)
 
 \return
 Returns the PS_Effects class instance for the specified effect
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (PS_Effects*) GetEffectFromID: (UInt32) id
{
    for(int i = 0; i < mEffects.size(); ++i)
    {
        if(mEffects[i]->GetEffectID() == id)
            return mEffects[i];
    }
    
    return nullptr;
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Gets an effect corresponding to the index
 
 \param index
 (Index needed to access)
 
 \return
 Returns the PS_Effects class instance for the specified effect
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (PS_Effects*) GetEffectFromIndex: (unsigned) index
{
    return mEffects[index];
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Gets the list of IDs
 
 \return
 Returns a vector with the effect IDs
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (std::vector<UInt32>) GetEffects
{
    return mEffectIDs;
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Initializes the Audio Unit Graph
 
 \return
 Does not return anything
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (void) initializeGraph
{
    result = noErr;
    
    result = NewAUGraph(&mGraph);
    
    // Store Output Description and add the node
    mCompDesc = {kAudioUnitType_Output, kAudioUnitSubType_HALOutput, kAudioUnitManufacturer_Apple, 0, 0};
    
    result = AUGraphAddNode(mGraph, &mCompDesc, &outputNode);
    
    if (result)
    {
        printf("AUGraphAddNode 1 result %lu %4.4s\n", (unsigned long)result, (char*)&result);
        return;
    }
    
    // Route incoming audio to the output
    result = AUGraphConnectNodeInput(mGraph, outputNode, 1, outputNode, 0);
    
    if (result)
    {
        printf("AUGraphAddNode result %d\n", result);
        return;
    }
                                
    // Open The Graph
    result = AUGraphOpen(mGraph);
    
    if (result)
    {
        printf("AUGraphOpen result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
    result = AUGraphNodeInfo(mGraph, outputNode, NULL, &output);
    
    if (result) {
        printf("AUGraphNodeInfo result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
    UInt32 size;
    
    AURenderCallbackStruct renderObj;
    renderObj.inputProc = &renderInput;
    
    
    // White Noise Testing
    /*result = AudioUnitSetProperty(mEffects[0]->GetEffectAU(),
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  0,
                                  &renderObj,
                                  sizeof(renderObj) );*/
    
    
    size = sizeof(mStreamDesc);
    
    
    UInt32 enableIO = 1;
    
    result = AudioUnitSetProperty(output,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1,
                         &enableIO,
                         sizeof(enableIO) );
    if (result)
    {
        printf("EnableIO result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
    result = AudioUnitSetProperty(output,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         0,
                         &enableIO,
                         sizeof(enableIO) );
    if (result)
    {
        printf("EnableIO result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
    result = AudioUnitGetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  1,
                                  &mStreamDesc,
                                  &size );
    
    if (result)
    {
        printf("StreamFormat result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
    result = AudioUnitGetProperty(output,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Output,
                                 0,
                                 &mStreamDesc,
                                 &size );
    
    if (result)
    {
        printf("StreamFormat result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }

    result = AUGraphInitialize(mGraph);
    
    if (result)
    {
        printf("AUGraphInitialize result %d\n", result);
        return;
    }
    
    CAShow(mGraph);
    
    result = AUGraphStart(mGraph);
    
    if (result)
    {
        printf("AUGraphStart result %u %4.4s\n", (unsigned int)result, (char*)&result);
        return;
    }
    
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Prints out the stream description structure
 
 \return
 Does not return anything
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
- (void) PrintStreamDescription
{
    std::cout << "STREAM DESCRIPTION START ++++++++++++++++++++++++++++++++++++++++++" << std::endl << std::endl;
    std::cout << "mBitsPerChannel: " << mStreamDesc.mBitsPerChannel << std::endl;
    std::cout << "mBytesPerFrame: " << mStreamDesc.mBytesPerFrame << std::endl;
    std::cout << "mBytesPerPacket: " << mStreamDesc.mBytesPerPacket << std::endl;
    std::cout << "mChannelsPerFrame: " << mStreamDesc.mChannelsPerFrame << std::endl;
    std::cout << "mFormateFlags: " << mStreamDesc.mFormatFlags << std::endl;
    std::cout << "mFormatID: " << mStreamDesc.mFormatID << std::endl;
    std::cout << "mFramesPerPacket: " << mStreamDesc.mFramesPerPacket << std::endl;
    std::cout << "mReserved: " << mStreamDesc.mReserved << std::endl;
    std::cout << "mSampelRate: " << mStreamDesc.mSampleRate << std::endl << std::endl;
    std::cout << "STREAM DESCRIPTION END ++++++++++++++++++++++++++++++++++++++++++++" << std::endl << std::endl;
}

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

@end
