//
//  GainPluginAudioUnit.m
//  GainPluginFramework
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

#import "GainPluginAudioUnit.h"

#import <AVFoundation/AVFoundation.h>

// MARK: Define parameter addresses. Any change here should be reflected in .h
const AudioUnitParameterID gain = 0;

// MARK: - Internal Interface properties
@interface GainPluginAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree *parameterTree;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;
@end

// MARK: - The AudioUnit implementation
@implementation GainPluginAudioUnit
@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) { return nil; }

	_kernelAdapter = [[GainPluginDSPKernelAdapter alloc] init];

	self.maximumFramesToRender = _kernelAdapter.maximumFramesToRender;

	[self setupAudioBuses];
	[self setupParameterTree];
	[self setupParameterCallbacks];
    return self;
}

#pragma mark - AUAudioUnit Setup

- (void)setupAudioBuses {
	// Create the input and output bus arrays.
	_inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
															 busType:AUAudioUnitBusTypeInput
															  busses: @[_kernelAdapter.inputBus]];
	_outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
															 busType:AUAudioUnitBusTypeOutput
															  busses: @[_kernelAdapter.outputBus]];
}

// MARK: Create parameter objects. These are -not- the DSPKernel parameters.
- (void)setupParameterTree {
    AUParameter *pGain = [AUParameterTree createParameterWithIdentifier:@"gain"
																	name:@"Gain"
																 address:gain
																	 min:0
																	 max:1
																	unit:kAudioUnitParameterUnit_LinearGain
																unitName:nil
																   flags:0
															valueStrings:nil
													 dependentParameters:nil];

    // Initialize the parameter values.
    // Remember to set its DSP equivalent value accordingly.
    pGain.value = 0.5;

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ pGain ]];
}

- (void)setupParameterCallbacks {
	// Make a local pointer to the kernel to avoid capturing self.
	__block GainPluginDSPKernelAdapter * kernelAdapter = _kernelAdapter;

	// implementorValueObserver is called when a parameter changes value.
	_parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
		[kernelAdapter setParameter:param value:value];
	};

	// implementorValueProvider is called when the value needs to be refreshed.
	_parameterTree.implementorValueProvider = ^(AUParameter *param) {
		return [kernelAdapter valueForParameter:param];
	};

	// A function to provide string representations of parameter values.
	_parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
		AUValue value = valuePtr == nil ? param.value : *valuePtr;

		return [NSString stringWithFormat:@"%.f", value];
	};
}

#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)inputBusses {
	return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
	return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
	if (_kernelAdapter.outputBus.format.channelCount != _kernelAdapter.inputBus.format.channelCount) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
		}
		// Notify superclass that initialization was not successful
		self.renderResourcesAllocated = NO;

		return NO;
	}

	[super allocateRenderResourcesAndReturnError:outError];
	[_kernelAdapter allocateRenderResources];
	return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
	[_kernelAdapter deallocateRenderResources];

    // Deallocate your resources.
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
	return _kernelAdapter.internalRenderBlock;
}

@end

