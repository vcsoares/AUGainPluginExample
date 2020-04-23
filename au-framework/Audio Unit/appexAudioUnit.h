//
//  appexAudioUnit.h
//  appex
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "appexDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface appexAudioUnit : AUAudioUnit

@property (nonatomic, readonly) appexDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
