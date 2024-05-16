//
//  Scene.swift
//  Project13
//
//  Created by Jinwoo Kim on 5/15/24.
//

import SpriteKit
import ARKit

public enum GameState {
    case Init
    case TapToStart
    case Playing
    case GameOver
}

class Scene: SKScene {
    var gameSate: GameState = .Init
    var anchor: ARAnchor?
    var emojis = "😁😂😛😝😋😜🤪😎🤓🤖🎃💀🤡"
    var spawnTime: TimeInterval = .zero
    var score: Int = .zero
    var lives: Int = 10
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
//        if let currentFrame = sceneView.session.currentFrame {
//            
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//            
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            sceneView.session.add(anchor: anchor)
//        }
        
        switch (gameSate) {
        case .Init:
            break
        case .TapToStart:
            playGame()
            break
        case .Playing:
            //checkTouches(touches)
            break
        case .GameOver:
            startGame()
            break
        }
    }
    
    func updateHUD(_ message: String) {
        guard let sceneView = self.view as? ARSKView else { return }
        
        let viewController = sceneView.delegate as! ViewController
        viewController.hudLabel.text = message
    }
    
    func startGame() {
        gameSate = .TapToStart
        updateHUD("- TAP TO START -")
    }
    
    func playGame() {
        gameSate = .Playing
        score = 0
        lives = 10
        spawnTime = 0
        
        addAnchor()
    }
    
    func stopGame() {
        gameSate = .GameOver
        updateHUD("GAME OVER! SCORE: " + String(score))
    }
    
    func addAnchor() {
        guard let sceneView = self.view as? ARSKView else { return }
        
        if let currentFrame = sceneView.session.currentFrame {
            var translation: matrix_float4x4 = matrix_identity_float4x4
            translation.columns.3.z = -0.5 // 50cm
            
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor!)
        }
    }
    
    func removeAnchor() {
        guard let sceneView = self.view as? ARSKView else { return }
        
        if let anchor {
            sceneView.session.remove(anchor: anchor)
        }
    }
}
