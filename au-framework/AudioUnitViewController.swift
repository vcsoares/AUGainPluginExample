//
//  AudioUnitViewController.swift
//  au-framework
//
//  Created by Vinícius Chagas on 23/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController {
    @IBOutlet weak var paramLabel: UILabel!
    
    public var audioUnit: appexAudioUnit? {
        didSet {
            audioUnit?.viewController = self

            if Thread.isMainThread {
                if self.isViewLoaded {
                    self.connectViewToAU()
                }
            } else {
                DispatchQueue.main.async {
                    if self.isViewLoaded {
                        self.connectViewToAU()
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            print("audio unit = nil")
            return
        }
        
        connectViewToAU()
    }
    
    fileprivate func connectViewToAU() {
        print("[\(Date())] Entrando na função \t \(#function)")
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard let freq = audioUnit?.parameterTree?.parameter(withAddress: AUParameterAddress(frequency)) else {
            print("oops")
            return
        }
        
        paramLabel.text = "Frequency: \(freq.value)"
    }
}
