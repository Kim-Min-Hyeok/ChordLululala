////
////  CanvasView.swift
////  ChordLululala
////
////  Created by 김민준 on 5/4/25.



import SwiftUI
import PencilKit


struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let isEditable: Bool
    var showToolbar: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isUserInteractionEnabled = isEditable
        
        // 도구바 설정
        if showToolbar {
            canvas.drawingPolicy = .pencilOnly
            setupToolbar(for: canvas)
        } else {
            canvas.drawingPolicy = .default
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isEditable
        
        // 도구바 표시 상태 업데이트
        if showToolbar {
            setupToolbar(for: uiView)
        } else {
            if let window = uiView.window,
               let toolPicker = PKToolPicker.shared(for: window) {
                toolPicker.setVisible(false, forFirstResponder: uiView)
                toolPicker.removeObserver(uiView)
            }
        }
        
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    // 도구바 설정을 위한 헬퍼 메서드
    private func setupToolbar(for canvas: PKCanvasView) {
        DispatchQueue.main.async {
            guard let window = canvas.window,
                  let toolPicker = PKToolPicker.shared(for: window) else {
                return
            }
            toolPicker.addObserver(canvas)
            toolPicker.setVisible(true, forFirstResponder: canvas)
            canvas.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>
        init(_ drawing: Binding<PKDrawing>) {
            self.drawing = drawing
        }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing.wrappedValue = canvasView.drawing
        }
    }
}
