//
//  appexAudioUnit.h
//  appex
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "appexDSPKernelAdapter.h"

// MARK: Expose parameter addresses. Any change here should be reflected in .m
extern const AudioUnitParameterID gain;

// MARK: - The AudioUnit interface
@interface appexAudioUnit : AUAudioUnit

@property (nonatomic, readonly) appexDSPKernelAdapter *kernelAdapter;
@property (weak) AudioUnitViewController *viewController;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
