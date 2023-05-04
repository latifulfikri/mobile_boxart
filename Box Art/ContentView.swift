//
//  ContentView.swift
//  Box Art
//
//  Created by Fikri Yuwi on 5/4/23.
//

import SwiftUI
import RealityKit
import ARKit

// membuat coaching overlay untuk petunjuk user pada ARView
extension ARView: ARCoachingOverlayViewDelegate {
  func addCoaching() {
    // membuat Object ARCoachingOverlayView
    let coachingOverlay = ARCoachingOverlayView()
    // scale fleksibel ke ukuran layar
    coachingOverlay.autoresizingMask = [
      .flexibleWidth, .flexibleHeight
    ]
    self.addSubview(coachingOverlay)
    // Set Augmented Reality goal
    coachingOverlay.goal = .anyPlane
    // Set ARSession
    coachingOverlay.session = self.session
    // Set delegate pada callback
    coachingOverlay.delegate = self
  }
}

// inisialisasi ARVariable untuk capture
struct ARVariables{
    static var arView: ARView!
}

struct ARViewContainer: UIViewRepresentable {
    // membuat ui view untuk AR
    func makeUIView(context: Context) -> ARView {
        // membuat object AR View
        ARVariables.arView = ARView(frame: .zero)
        // menambahkan coacing pada saat AR View bekerja
        ARVariables.arView.addCoaching()
        
        // Load the "Yogurt" scene dari "Experience" Reality File
        let yogurtAnchor = try! Experience.loadYogurt()
        
        // Menambahkan anchor ke scene
        ARVariables.arView.scene.anchors.append(yogurtAnchor)
        
        // mengembalikan arview
        return ARVariables.arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

struct ContentView : View {
    
    // item for send to share sheet
    @State var items : [Any] = []
    // untuk menampilkan sheet
    @State var sheet = false
    
    var body: some View {
        // membuat zstack dengan alignment bawah
        ZStack(alignment: .bottom){
            // memanggil ARViewContainer yang merupakan AR yang akan ditampilkan
            ARViewContainer().edgesIgnoringSafeArea(.all)
                    
            // membuat button/tombol
            Button {
                // melakukan snapshot dari arView yang dipilih
                ARVariables.arView.snapshot(saveToHDR: false) { (image) in
                    // Compress the image
                    guard let imageData = image?.pngData(),
                    let compressedImage = UIImage(data: imageData) else {
                        return
                    }
                    // menghapus semua data pada items
                    items.removeAll()
                    // menambahkan data items dengan gambar hasil snapshot
                    items.append(compressedImage)
                }
                // menampilkan share sheet
                sheet.toggle()
                        
            } label: {
                // label pada button
                Image(systemName: "camera")
                    .frame(width:60, height:60)
                    .font(.title)
                    .background(.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding()
            }
        }
        // mendeklarasikan sheet mengacu pada nilai sheet
        .sheet(isPresented: $sheet, content: {
            // deklarasi share sheet dengan mengirimkan data items
            ShareSheet(item: items)
        })
    }
}

struct ShareSheet : UIViewControllerRepresentable {
    
    // parameter item untuk dishare
    var item : [Any]
    
    // membuat ui controller
    func makeUIViewController(context: Context) -> some UIViewController {
        // inisialisasi controller
        let controller = UIActivityViewController(activityItems: item, applicationActivities: nil)
        // mengembalikan nilai controller
        return controller
    }
    
    // update ui controller jika ada perubahan
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
