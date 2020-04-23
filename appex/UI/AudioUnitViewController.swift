//
//  AudioUnitViewController.swift
//  appex
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import CoreAudioKit
import au_framework

extension AudioUnitViewController: AUAudioUnitFactory {

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try appexAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
}

