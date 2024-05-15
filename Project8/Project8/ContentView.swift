//
//  ContentView.swift
//  Project8
//
//  Created by Jinwoo Kim on 5/15/24.
//

import SwiftUI
import ARKit
import RealityKit
import UniformTypeIdentifiers

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        let pepperARObjectURL: URL = Bundle.main.url(forResource: "pepper", withExtension: UTType.arReferenceObject.preferredFilenameExtension)!
        
        let arReferenceObject: ARReferenceObject = try! ARReferenceObject(archiveURL: pepperARObjectURL)
        
        let configuration: ARWorldTrackingConfiguration = .init()
        configuration.detectionObjects = .init(arrayLiteral: arReferenceObject)
        
        arView.automaticallyConfigureSession = false
        arView.session.delegate = context.coordinator
        arView.session.run(configuration)
        
        
//        let objAnchor: AnchorEntity = .init(anchor: arObject)
//        // Create a cube model
//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05
//
//        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
//
//        // Add the horizontal plane anchor to the scene
//        arView.scene.anchors.append(anchor)

        context.coordinator.arView = arView
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let arView else { return }
            
            guard let pepperAnchor = anchors.first(where: { $0.name == "pepper" }) else { return }
            
            print(pepperAnchor)
            
            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
            let model = ModelEntity(mesh: mesh, materials: [material])
            model.transform.translation.y = 0.05
            
            // Create horizontal plane anchor for the content
//            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            
            let result = AnchorEntity(anchor: pepperAnchor)
            result.addChild(model)
            
            arView.scene.addAnchor(result)
        }
        
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            arView?.scene.anchors.removeAll()
        }
    }
}

#Preview {
    ContentView()
}
