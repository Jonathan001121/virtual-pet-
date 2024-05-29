//
//  ContentView.swift
//  AR
//
//  Created by Chi Chi Chan on 24/11/2023.
//
import SwiftUI
import RealityKit
import ARKit
struct ContentView : View {
 
    var body: some View {
        TabView {
            Ar().tabItem{
                Image(systemName: "info.circle.fill")
                Text("Cat")
            }
            CatView().tabItem {
                Image(systemName: "info.circle.fill")
                Text("Cat")
            }

            }
        
    }
}
struct Ar: View {
    @ObservedObject var arViewModel = ARViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var selectedAnimationIndex = 5
  var body: some View {
    VStack {
        ARViewContainer(viewModel: arViewModel, ARAnimationIndex: speechRecognizer.ARAnimationIndex).ignoresSafeArea()
        AudioPlayerView(selectedAnimationIndex: $selectedAnimationIndex)
        HStack{
            
            Button("turn left") {
                arViewModel.turnLeftAnimation()
            }
            Button("Move") {
                arViewModel.playAnimation()
            }
            Button("turn right") {
                arViewModel.turnRightAnimation()
            }
            
        }
    }.onAppear(perform: {
        speechRecognizer.transcribe()
    })
  }
    
//    func recogniseCommand(){
//        print("success")
//        print(speechRecognizer.selectedAnimationIndex)
//        if speechRecognizer.selectedAnimationIndex == 5 {
//            arViewModel.playAnimation()
//        } else if speechRecognizer.selectedAnimationIndex == 6{
//            arViewModel.turnLeftAnimation()
//        } else if speechRecognizer.selectedAnimationIndex == 7{
//            arViewModel.turnRightAnimation()
//        }
//    }
}

struct ARViewContainer: UIViewRepresentable {

  @ObservedObject var viewModel = ARViewModel()
    var ARAnimationIndex = 0

//
  func makeUIView(context: Context) -> ARView {
    
    let arView = ARView(frame: .zero,cameraMode: .ar, automaticallyConfigureSession: true)
    viewModel.loadCat()
    arView.scene.anchors.append(viewModel.catAnchor)
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {
      if ARAnimationIndex == 6 {
          viewModel.playAnimation()
      } else if ARAnimationIndex == 7{
          viewModel.turnLeftAnimation()
      } else if ARAnimationIndex == 8{
          viewModel.turnRightAnimation()
      }

  }
}

class ARViewModel: ObservableObject {
    let catAnchor = AnchorEntity(plane:.horizontal)
    let cat=try! Entity.loadModel(named: "walking")
      func loadCat() {
          cat.scale = SIMD3<Float>(repeating: 0.08)
          let newPosition = SIMD3<Float>(x: 0, y: 0, z: 0)
          cat.position = newPosition
          let rotationAngle: Float = .pi // 180 degrees
          let rotationQuaternion = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
          cat.transform.rotation = rotationQuaternion
          print(cat)
          print(cat.model)
          catAnchor.addChild(cat)
  }
    
    
  func playAnimation(){
      let temp:Transform=RealityKit.Transform(translation: SIMD3<Float>(0.0, 0.0, -5.0))
          cat.move(to: temp, relativeTo: cat, duration: 8)
          let animation=cat.availableAnimations.first
          cat.playAnimation( animation!.repeat(duration:5), transitionDuration: 0.5, startsPaused: false)
    
  }
    func turnLeftAnimation(){
        let rotationAngle: Float = .pi/2
        let temp = RealityKit.Transform(rotation: simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0)))
            cat.move(to: temp, relativeTo: cat, duration: 1)
            let animation=cat.availableAnimations.first
            cat.playAnimation( animation!.repeat(duration:1), transitionDuration: 0.5, startsPaused: false)
      
    }
    func turnRightAnimation(){
        let rotationAngle: Float = .pi/2
        let temp = RealityKit.Transform(rotation: simd_quatf(angle: -rotationAngle, axis: SIMD3<Float>(0, 1, 0)))
            cat.move(to: temp, relativeTo: cat, duration: 1)
            let animation=cat.availableAnimations.first
            cat.playAnimation( animation!.repeat(duration:1), transitionDuration: 0.5, startsPaused: false)
      
    }
}


