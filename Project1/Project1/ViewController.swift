//
//  ViewController.swift
//  Project1
//
//  Created by Jinwoo Kim on 5/14/24.
//

import UIKit
import RealityKit

final class ViewController: UIViewController {
    @IBOutlet weak var arView: ARView!
    var tankAnchor: TinyToyTank._TinyToyTank?
    var isActionPlaying: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tankAnchor = try! TinyToyTank.load_TinyToyTank()
        
        tankAnchor!.turret!.setParent(tankAnchor!.tank, preservingWorldTransform: true)
        
        tankAnchor?.actions.actionComplete.onAction = { entity in
            print(entity?.name)
            self.isActionPlaying = false
        }
        arView.scene.addAnchor(tankAnchor!)
    }

    @IBAction func tankRightPressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        
        tankAnchor!.notifications.tankRight.post()
    }
    
    @IBAction func tankForwardPressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        tankAnchor!.notifications.tankForward.post()
    }
    
    @IBAction func tankLeftPressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        tankAnchor!.notifications.tankLeft.post()
    }
    
    @IBAction func turretRightPressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        tankAnchor!.notifications.turretRight.post()
    }
    
    @IBAction func cannonFirePressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        tankAnchor!.notifications.cannonFire.post()
    }
    
    @IBAction func turretLeftPressed(_ sender: UIButton) {
//        if self.isActionPlaying { return }
//        else { self.isActionPlaying = true }
        tankAnchor!.notifications.turretLeft.post()
    }
}
