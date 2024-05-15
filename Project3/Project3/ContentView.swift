//
//  ContentView.swift
//  Project3
//
//  Created by Jinwoo Kim on 5/15/24.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct ContentView : View {
    let entity: UntitledEntity = {
        let url: URL = Bundle.main.url(forResource: "Untitled", withExtension: UTType.realityFile.preferredFilenameExtension)!
        let entity: RealityKit.Entity = try! .load(contentsOf: url)
        
        let result: UntitledEntity = .init()
        result.addChild(entity)
        
        return result
    }()
    
    var body: some View {
        ARViewContainer(entity: entity).edgesIgnoringSafeArea(.all)
            .overlay { 
                Button("Trigger") { 
                    
                }
            }
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        .init(entity: entity)
    }
    
    let entity: UntitledEntity
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        
        arView.scene.anchors.append(entity)
        
        let tapGesture: UITapGestureRecognizer = .init(target: context.coordinator, action: #selector(Coordinator.foo(_:)))
        arView.addGestureRecognizer(tapGesture)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    class Coordinator {
        let entity: UntitledEntity
        
        init(entity: UntitledEntity) {
            self.entity = entity
        }
        
        @objc func foo(_ sender: UITapGestureRecognizer) {
            let arView: ARView = sender.view as! ARView
            
            let userInfo: [Swift.String: Any] = [
                "RealityKit.NotificationTrigger.Scene": arView.scene,
                "RealityKit.NotificationTrigger.Identifier": "Behavior"
            ]

            Foundation.NotificationCenter.default.post(name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotificationTrigger"), object: self, userInfo: userInfo)
        }
    }
}

final class UntitledEntity: RealityKit.Entity, RealityKit.HasAnchoring {
    
}

#Preview {
    ContentView()
}
