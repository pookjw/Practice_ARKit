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

import SwiftUI
import RealityKit
import ARKit

var arView: ARView!
var robot: Experience.Robot!

struct ContentView : View {
    
    @State var propId: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(propId: $propId).edgesIgnoringSafeArea(.all)
            HStack {
                
                Spacer()
                
                Button(action: {
                    self.propId = self.propId <= 0 ? 0 : self.propId - 1
                }) {
                    Image("PreviousButton").clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    self.TakeSnapshot()
                }) {
                    Image("ShutterButton")
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    self.propId = self.propId >= 3 ? 3 : self.propId + 1
                }) {
                    Image("NextButton").clipShape(Circle())
                }
                
                Spacer()
            }
        }
    }
    
    func TakeSnapshot() {
        arView.snapshot(saveToHDR: false) { (image) in
            let compressedImage = UIImage(data: (image?.pngData())!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var propId: Int
    
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        robot = nil
        
        arView.scene.anchors.removeAll()
        
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options:[.resetTracking, .removeExistingAnchors])
        
        switch(propId) {
        case 0: // Eyes
            let arAnchor = try! Experience.loadEyes()
            uiView.scene.anchors.append(arAnchor)
            break
        case 1: // Glasses
            let arAnchor = try! Experience.loadGlasses()
            uiView.scene.anchors.append(arAnchor)
            break
        case 2: // Mustache
            let arAnchor = try! Experience.loadMustache()
            uiView.scene.anchors.append(arAnchor)
            break
        case 3:
            let arAnchor = try! Experience.loadRobot()
            uiView.scene.anchors.append(arAnchor)
            robot = arAnchor
            break
        default:
            break
        }
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler.init(self)
    }
    
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        var arViewContainer: ARViewContainer
        var isLassersDone = true
        
        init(_ control: ARViewContainer) {
            self.arViewContainer = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let robot else { return }
            
            var faceAnchor: ARFaceAnchor!
            for anchor in anchors {
                if let a = anchor as? ARFaceAnchor {
                    faceAnchor = a
                }
            }
            
            let blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = faceAnchor.blendShapes
            let eyeBlinkLeft: Float? = blendShapes[.eyeBlinkLeft]?.floatValue
            let eyeBlinkRight: Float? = blendShapes[.eyeBlinkRight]?.floatValue
            let browIneerUp: Float? = blendShapes[.browInnerUp]?.floatValue
            let browLeft: Float? = blendShapes[.browDownLeft]?.floatValue
            let browRight: Float? = blendShapes[.browDownRight]?.floatValue
            let jawOpen: Float? = blendShapes[.jawOpen]?.floatValue
            
            robot.robotEyeLid1!.orientation = simd_mul(
                simd_quatf(angle: Deg2Rad(-120 + (90 * eyeBlinkLeft!)), axis: [1, 0, 0]),
                simd_quatf(angle: Deg2Rad((90 * browLeft!) - (30 * browIneerUp!)), axis: [0, 0, 1])
            )
            
            robot.robotEyeLid2!.orientation = simd_mul(
                simd_quatf(angle: Deg2Rad(-120 + (90 * eyeBlinkRight!)), axis: [1, 0, 0]),
                simd_quatf(angle: Deg2Rad((-90 * browRight!) - (-30 * browIneerUp!)), axis: [0, 0, 1])
            )
            
            robot.robotJaw!.orientation = simd_quatf(
                angle: Deg2Rad(-100 + (60 * jawOpen!)),
                axis: [1, 0, 0]
            )
            
            if (self.isLassersDone == true && jawOpen! > 0.5) {
                self.isLassersDone = false
                
                Task { @MainActor in
                    robot.notifications.showLasers.post()
                    robot.actions.lasersDone.onAction = { _ in
                        self.isLassersDone = true
                    }
                }
            }
        }
        
        func Deg2Rad(_ value: Float) -> Float {
            return value * .pi / 180.0
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
