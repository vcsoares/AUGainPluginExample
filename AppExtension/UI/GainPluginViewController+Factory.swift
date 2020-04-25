//
//  AudioUnitViewController.swift
//  GainPlugin
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import CoreAudioKit
import GainPluginFramework

extension GainPluginViewController: AUAudioUnitFactory {

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try GainPluginAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    
}

