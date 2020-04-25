//
//  AudioUnitViewController.swift
//  GainPluginFramework
//
//  Created by Vinícius Chagas on 23/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import CoreAudioKit

public class GainPluginViewController: AUViewController {
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var gainSlider: UISlider!
    
    private var gainParameter: AUParameter!
    
    private var parameterObserverToken: AUParameterObserverToken?
    private var isConnectedToAU: Bool = false
    
    public var audioUnit: GainPluginAudioUnit? {
        didSet {
            audioUnit?.viewController = self

            Thread.performOnMain {
                if self.isViewLoaded {
                    self.connectViewToAU()
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
        guard isConnectedToAU == false else {
            print("Already connected to AU")
            return
        }
        
        print("\(#function)")
        
        // Get the parameter tree and add observers for any parameters
        // that the UI needs to keep in sync with the AudioUnit.
        guard let gain = audioUnit?.parameterTree?.parameter(withAddress: AUParameterAddress(gain)) else {
            print("❌ Couldn't find required parameters in parameter tree.")
            return
        }
        
        gainParameter = gain
        
        // Observe value changes made to parameters.
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
        
        self.isConnectedToAU = true
        updateUI()
    }
    
    @IBAction func gainSliderValueChanged(_ sender: UISlider) {
        gainParameter.setValue(sender.value, originator: parameterObserverToken)
        updateUI()
    }
    
    fileprivate func updateUI() {
        paramLabel.text = "\(gainParameter.displayName): \(gainParameter.value)"
    }
}

public extension Thread {
    
    static func performOnMain(_ procedure: @escaping (() -> Void)) {
        if Thread.isMainThread {
            procedure()
        } else {
            DispatchQueue.main.async {
                procedure()
            }
        }
    }
    
}
