import UIKit
import PencilKit
import SwiftUI

//MARK: - UIkit의 pecilkit을 SwiftUI에서도 사용하기 위해 감싸줌
struct PencilKitView: UIViewRepresentable {
    let canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
