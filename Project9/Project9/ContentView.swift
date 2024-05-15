//
//  ContentView.swift
//  Project9
//
//  Created by Jinwoo Kim on 5/15/24.
//

import SwiftUI
import RealityKit

var arView: ARView!

struct ContentView : View {
    @State var propId: Int = 0
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(propId: $propId).edgesIgnoringSafeArea(.all)
         
            HStack {
                Button(action: {
                    self.propId = (self.propId <= 0) ? 0 : (self.propId - 1)
                }, label: {
                    Image(.previousButton).clipShape(Circle())
                })
                
                Spacer()
                
                Button(action: {
                    self.TakeSnapshot()
                }, label: {
                    Image(.shutterButton).clipShape(Circle())
                })
                
                Spacer()
                
                Button(action: {
                    self.propId = (self.propId >= 2) ? 2 : (self.propId + 1)
                }, label: {
                    Image(.nextButton).clipShape(Circle())
                })
            }
        }
    }
    
    func TakeSnapshot() {
        arView.snapshot(saveToHDR: false) { image in
            let compressedImage = UIImage(data: image!.pngData()!)!
            
            UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var propId: Int
    
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        arView.debugOptions = [.showAnchorGeometry, .showAnchorOrigins, .showFeaturePoints, .showPhysics, .showSceneUnderstanding, .showWorldOrigin]

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

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
