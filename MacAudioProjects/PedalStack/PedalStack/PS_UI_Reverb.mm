//
//  PS_UI_Reverb.m
//  PedalStack
//
//  Created by Poppy on 11/30/16.
//  Copyright © 2016 Deepak Chennakkadan. All rights reserved.
//

#import "PS_UI_Reverb.h"
#import "PS_UI_Manager.h"

@implementation PS_UI_Reverb

- (void) awakeFromNib
{
    
    [label_DryWetMix setIntegerValue: 100];
    [label_SmallLargeMix setIntegerValue: 50];
    [label_PreDelay setFloatValue: 0.025];
    [label_ModulationRate setFloatValue: 1.0];
    [label_ModulationDepth setFloatValue: 0.2];
    
    [label_SmallSize setFloatValue: 0.06];
    [label_SmallDensity setFloatValue: 0.28];
    [label_SmallBrightness setFloatValue: 0.96];
    [label_SmallDelayRange setFloatValue: 0.5];
    
    [label_LargeSize setFloatValue: 3.07];
    [label_LargeDelay setFloatValue: 0.035];
    [label_LargeDensity setFloatValue: 0.82];
    [label_LargeDelayRange setFloatValue: 0.3];
    [label_LargeBrightness setFloatValue: 0.49];
}

-(IBAction)Reverb_DryWetMix:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_DryWetMix];
    [label_DryWetMix setIntegerValue: value];
}

-(IBAction)Reverb_SmallLargeMix:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_SmallLargeMix];
    [label_SmallLargeMix setIntegerValue: value];
}

-(IBAction)Reverb_PreDelay:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_PreDelay];
    [label_PreDelay setFloatValue: value];
}

-(IBAction)Reverb_ModulationRate:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_ModulationRate];
    [label_ModulationRate setFloatValue: value];
}

-(IBAction)Reverb_ModulationDepth:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_ModulationDepth];
    [label_ModulationDepth setFloatValue: value];
}

-(IBAction)Reverb_SmallSize:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_SmallSize];
    [label_SmallSize setFloatValue: value];
}

-(IBAction)Reverb_SmallDensity:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_SmallDensity];
    [label_SmallDensity setFloatValue: value];
}

-(IBAction)Reverb_SmallBrightness:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_SmallBrightness];
    [label_SmallBrightness setFloatValue: value];
}

-(IBAction)Reverb_SmallDelayRange:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_SmallDelayRange];
    [label_SmallDelayRange setFloatValue: value];
}

-(IBAction)Reverb_LargeSize:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_LargeSize];
    [label_LargeSize setFloatValue: value];
}

-(IBAction)Reverb_LargeDelay:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_LargeDelay];
    [label_LargeDelay setFloatValue: value];
}

-(IBAction)Reverb_LargeDensity:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_LargeDensity];
    [label_LargeDensity setFloatValue: value];
}

-(IBAction)Reverb_LargeDelayRange:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_LargeDelayRange];
    [label_LargeDelayRange setFloatValue: value];
}

-(IBAction)Reverb_LargeBrightness:(id)sender
{
    float value = [sender floatValue];
    [(PS_UI_Manager *) [NSApp delegate] setUIParam:value arg2:kAudioUnitSubType_MatrixReverb arg3:kReverbParam_LargeBrightness];
    [label_LargeBrightness setFloatValue: value];
}
@end

