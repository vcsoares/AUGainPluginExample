//
//  AudioUnitViewController.swift
//  au-framework
//
//  Created by Vinícius Chagas on 23/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController {
    public var audioUnit: AUAudioUnit?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
}
