//
//  ViewController.swift
//  Project13
//
//  Created by Jinwoo Kim on 5/15/24.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
    @IBOutlet var sceneView: ARSKView!
    @IBOutlet var hudLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, 
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default, handler: nil)) 
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let spawnNode = SKNode()
        spawnNode.name = "SpawnPoint"
        
        let boxNode = SKLabelNode(text: "🆘")
        boxNode.verticalAlignmentMode = .center
        boxNode.horizontalAlignmentMode = .center
        boxNode.zPosition = 100.0
        boxNode.setScale(1.5)
        spawnNode.addChild(boxNode)
        
        return spawnNode
    }
    
    func view(_ view: ARSKView, willUpdate node: SKNode, for anchor: ARAnchor) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showAlert("Session Failure", error.localizedDescription)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            showAlert("Tracking Limited", "AR not available")
            break
        case .limited(let reason):
            switch reason {
            case .initializing:
                break
            case .excessiveMotion:
                showAlert("Tracking Limited", "Excessive motion!")
            case .insufficientFeatures:
                showAlert("Tracking Limited", "Insufficient features!")
            case .relocalizing:
                break
            }
        case .normal:
            break
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        showAlert("AR Session", "Session was interrupted!")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        let scene = sceneView.scene as! Scene
        scene.startGame()
    }
}
