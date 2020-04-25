//
//  GainPluginFramework.h
//  GainPluginFramework
//
//  Created by Vinícius Chagas on 23/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for GainPlugin.
FOUNDATION_EXPORT double GainPluginFrameworkVersionNumber;

//! Project version string for GainPlugin.
FOUNDATION_EXPORT const unsigned char GainPluginFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GainPluginFramework/PublicHeader.h>
@class GainPluginViewController;
#import "GainPluginDSPKernelAdapter.h"
#import "GainPluginAudioUnit.h"
