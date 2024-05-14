//
//  ContentView.swift
//  Project1_2
//
//  Created by Jinwoo Kim on 5/14/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State var model: ModelEntity
    
    init() {
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05
        
        
        
        _model = .init(initialValue: model)
    }
    
    var body: some View {
        ARViewContainer(model: model).edgesIgnoringSafeArea(.all)
            .overlay { 
                Button("Move Right") { 
                    model.transform.translation.x = .zero
                    
                    let fromToAnimation: FromToByAnimation<Transform> = .init(
                        from: .init(translation: .zero),
                        to: .init(translation: .init(x: 0.1, y: .zero, z: .zero)),
                        duration: 0.5,
                        timing: .easeInOut,
                        bindTarget: .transform
                    )
                    
                    let animationResource: RealityKit.AnimationResource = try! .generate(with: fromToAnimation)
                    
                    let controller: AnimationPlaybackController = model.playAnimation(animationResource, transitionDuration: 0.5, startsPaused: false)
                }
            }
            .task {
                for await notification in NotificationCenter.default.notifications(named: .init("RealityKit.NotifyAction")) {
                    print(notification)
                }
            }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let model: ModelEntity
    
    init(model: ModelEntity) {
        self.model = model
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .null)

        // Create a cube model
        

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)
        

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
