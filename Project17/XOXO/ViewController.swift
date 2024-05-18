/// Copyright (c) 2022 Razeware LLC

///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Combine
import RealityKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSessionDelegate {
    
    // MARK: - Properties
    var playerColor = UIColor.blue
    
    var gridModelEntityX: ModelEntity?
    var gridModelEntityY: ModelEntity?
    var tileModelEntity: ModelEntity?
    
    var multipeerSession: MultipeerSession?
    var peerSessionIDs = [MCPeerID: String]()
    var sessionIDObservation: NSKeyValueObservation?
    
    var cancellable: (any Cancellable)?
    
    // MARK: - IBOutlets & IBActions
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var message: UILabel!
    
    @IBAction func player1ButtonPressed(_ sender: Any) {
        playerColor = .blue
    }
    
    @IBAction func player2ButtonPressed(_ sender: Any) {
        playerColor = .red
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        removeAnchors()
    }
    
    // MARK: - AR View Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initARView()
        initModelEntities()
        initGestures()
        initMultipeerSession()
    }
    
    func initARView() {
        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
        
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = [.horizontal]
        arConfiguration.environmentTexturing = .automatic
        arConfiguration.isCollaborationEnabled = true
        arView.session.run(arConfiguration)
        
        
//        cancellable = arView.scene.publisher(for: SynchronizationEvents.OwnershipRequest.self, componentType: SynchronizationComponent.self)
//            .sink { request in
//                request.accept()
//            }
    }
}

// MARK: - Model Entity Functions

extension ViewController {
    func initModelEntities() {
        gridModelEntityX = ModelEntity(
            mesh: .generateBox(size: SIMD3(x: 0.3, y: 0.01, z: 0.01)),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
        
        gridModelEntityY = ModelEntity(
            mesh: .generateBox(size: SIMD3(x: 0.01, y: 0.01, z: 0.3)),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
        
        tileModelEntity = ModelEntity(
            mesh: .generateBox(size: SIMD3(x: 0.07, y: 0.01, z: 0.07)),
            materials: [SimpleMaterial(color: .gray, isMetallic: true)]
        )
        
        tileModelEntity!.generateCollisionShapes(recursive: false)
    }
    
    func cloneModelEntity(_ modelEntity: ModelEntity, position: SIMD3<Float>) -> ModelEntity {
        let newModelEntity = modelEntity.clone(recursive: false)
        newModelEntity.position = position
        newModelEntity.synchronization?.ownershipTransferMode = .manual
        return newModelEntity
    }
    
    func addGameBoardAnchor(transform: simd_float4x4) {
        let arAnchor = ARAnchor(name: "XOXO Grid", transform: transform)
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        
        anchorEntity.addChild(cloneModelEntity(gridModelEntityY!, position: SIMD3(x: 0.05, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(gridModelEntityY!, position: SIMD3(x: -0.05, y: 0, z: 0)))
        
        anchorEntity.addChild(cloneModelEntity(gridModelEntityX!, position: SIMD3(x: 0, y: 0, z: 0.05)))
        anchorEntity.addChild(cloneModelEntity(gridModelEntityX!, position: SIMD3(x: 0, y: 0, z: -0.05)))
        
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: -0.1, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0.1, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: -0.1, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0.1, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: -0.1, y: 0, z: 0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0, y: 0, z: 0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!, position: SIMD3(x: 0.1, y: 0, z: 0.1)))
        
        anchorEntity.anchoring = AnchoringComponent(arAnchor) // 없어도 되는듯?

        
        arView.scene.addAnchor(anchorEntity)
        arView.session.add(anchor: arAnchor)
        
        // 책이 잘못 설명함 - newModelEntity.synchronization?.ownershipTransferMode = .manual이 되어야 함
        // https://github.com/duzhaoquan/ARkitDemo/blob/28fe5778f69a019caad01963557bdcb7b556c801/ARKitDeamo/AdvancedChapter/SyncARSession.swift#L151
//        anchorEntity.synchronization!.ownershipTransferMode = .manual
        cancellable = arView.scene.subscribe(to: SynchronizationEvents.OwnershipRequest.self, { event in
            event.accept()
        })
    }
}

// MARK: - Gesture Functions

extension ViewController {
    func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.arView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        tap.require(toFail: doubleTap)
        self.arView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer?) {
        guard let touchLocation = recognizer?.location(in: self.arView) else { return }
        
//        if let hitEntity = self.arView.entity(at: touchLocation) {
//            let modelEntity = hitEntity as! ModelEntity
//            
//            modelEntity.model?.materials = [
//                SimpleMaterial(color: self.playerColor, isMetallic: true)
//            ]
//            
//            return
//        }
        
        if let hitEntity = self.arView.entity(at: touchLocation) {
            if hitEntity.isOwner {
                let modelEntity = hitEntity as! ModelEntity
                
                modelEntity.model?.materials = [
                    SimpleMaterial(color: self.playerColor, isMetallic: true)
                ]
            } else {
                hitEntity.requestOwnership { result in
                    if result == .granted {
                        let modelEntity = hitEntity as! ModelEntity
                        modelEntity.model?.materials = [
                            SimpleMaterial(color: self.playerColor, isMetallic: true)
                        ]
                    }
                }
            }
            
            return
        }
        
        //
        
//        let results: [ARRaycastResult] = self.arView.raycast(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal)
//        
//        if let firstResult = results.first {
//            self.addGameBoardAnchor(transform: firstResult.worldTransform)
//        } else {
//            self.message.text = "[WARNING] NO surface detected!"
//        }
        
        if let query: ARRaycastQuery = self.arView.makeRaycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal) {
            let results = self.arView.session.raycast(query)
            
            if let firstResult = results.first {
                self.addGameBoardAnchor(transform: firstResult.worldTransform)
            } else {
                self.message.text = "[WARNING] NO surface detected!"
            }
        }
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.arView)
        
        if let hitEntity = self.arView.entity(at: touchLocation),
           !hitEntity.isOwner {
            self.arView.scene.synchronizationService?.giveOwnership(of: hitEntity, toPeer: multipeerSession!.myPeerID)
        }
    }
}


// MARK: - Multipeer Session Functions

extension ViewController {
    func initMultipeerSession() {
        sessionIDObservation = observe(\.arView?.session.identifier, options: [.new], changeHandler: { object, change in
            print("Current SessionID: \(String(describing: change.newValue!))")
            
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        })
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData(_:from:), peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
        
        guard let multipeerConnectivityService = multipeerSession?.multipeerConnectivityService else {
            fatalError()
        }
        
        arView.scene.synchronizationService = multipeerConnectivityService
        self.message.text = "Waiting for peers..."
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                self.message.text = "Peer connected!"
                let anchorEntity = AnchorEntity(anchor: participantAnchor)
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession else { return false }
        
        sendMessage("Peer discovered!")
        
        if multipeerSession.connectedPeers.count > 2 {
            sendMessage("[WARNING] Max connections reached!")
            return false
        } else {
            return true
        }
    }
    
    func peerJoined(_ peer: MCPeerID) {
        sendMessage("Hold phones together...")
        sendARSessionIDTo(peers: [peer])
    }
    
    func peerLeft(_ peer: MCPeerID) {
        sendMessage("Peer Left!")
        peerSessionIDs.removeValue(forKey: peer)
    }
    
    private func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
}

// MARK: - Helper Functions

extension ViewController {
    func sendMessage(_ message: String) {
        DispatchQueue.main.async {
            self.message.text = message
        }
    }
    
    func removeAnchors() {
        guard let frame: ARFrame = arView.session.currentFrame else { return }
        
        
        for anchor in frame.anchors {
            arView.session.remove(anchor: anchor)
        }
    }
}



