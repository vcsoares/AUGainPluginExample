//
//  ViewController.swift
//  au-test
//
//  Created by Vinícius Chagas on 22/04/20.
//  Copyright © 2020 Vinícius Chagas. All rights reserved.
//

import UIKit
import AVFoundation
import au_framework

// The AudioComponentDescription matching the AppEx Info.plist
private var componentDescription: AudioComponentDescription = {

    // Ensure that AudioUnit type, subtype, and manufacturer match the extension's Info.plist values
    var componentDescription = AudioComponentDescription()
    componentDescription.componentType = kAudioUnitType_Effect
    componentDescription.componentSubType = 0x74657374 /*'test'*/
    componentDescription.componentManufacturer = 0x44656d6f /*'Demo'*/
    componentDescription.componentFlags = 0
    componentDescription.componentFlagsMask = 0

    return componentDescription
}()

private let componentName = "Demo: GainPlugin"

class ViewController: UIViewController {

    @IBOutlet weak var auContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let url = Bundle.main.builtInPlugInsURL?.appendingPathComponent("GainPlugin.appex"),
            let appexBundle = Bundle(url: url) else {
                fatalError("Could not find app extension bundle URL.")
        }

        let storyboard = UIStoryboard(name: "MainInterface", bundle: appexBundle)
        guard let controller = storyboard.instantiateInitialViewController() as? GainPluginViewController else {
            fatalError("Unable to instantiate AudioUnitViewController")
        }
        
        AUAudioUnit.registerSubclass(GainPluginAudioUnit.self,
                                     as: componentDescription,
                                     name: componentName,
                                     version: UInt32.max)

        AVAudioUnit.instantiate(with: componentDescription) { audioUnit, error in
            guard error == nil, let audioUnit = audioUnit else {
                fatalError("Could not instantiate AU: \(error!.localizedDescription))")
            }
            controller.audioUnit = audioUnit.auAudioUnit as? GainPluginAudioUnit
        }
        
        if let view = controller.view {
            addChild(controller)
            view.frame = auContainer.bounds
            auContainer.addSubview(view)
            view.pinToSuperviewEdges()
            controller.didMove(toParent: self)
        }
    }


}

public extension UIView {
    func pinToSuperviewEdges() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
