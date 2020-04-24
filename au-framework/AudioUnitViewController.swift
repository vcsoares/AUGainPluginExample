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
    @IBOutlet weak var gainSlider: UISlider!
    
    private var gainParameter: AUParameter!
    
    private var parameterObserverToken: AUParameterObserverToken?
    
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
        
        guard audioUnit != nil else {
            print("audio unit = nil")
            return
        }
        
        connectViewToAU()
    }
    
    fileprivate func connectViewToAU() {
        print("[\(Date())] Entrando na função \t \(#function)")
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard let gain = audioUnit?.parameterTree?.parameter(withAddress: AUParameterAddress(gain)) else {
            print("oops")
            return
        }
        
        gainParameter = gain
        
        // Observe value changes made to the cutoff and resonance parameters.
        parameterObserverToken =
            audioUnit?.parameterTree?.token(byAddingParameterObserver: { [weak self] address, value in
                guard let self = self else { return }

                // This closure is being called by an arbitrary queue. Ensure
                // all UI updates are dispatched back to the main thread.
                if [gain.address].contains(address) {
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
            })
        
        updateUI()
    }
    
    fileprivate func updateUI() {
        paramLabel.text = "\(gainParameter.displayName): \(gainParameter.value)"
    }
    
    @IBAction func gainSliderValueChanged(_ sender: UISlider) {
        gainParameter.setValue(sender.value, originator: parameterObserverToken)
        updateUI()
    }
}
