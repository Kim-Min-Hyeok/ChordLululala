//
//  CanvasView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/4/25.
//

import SwiftUI
import PencilKit

/// SwiftUI 에서 PKCanvasView 를 쓰기 위한 UIViewRepresentable
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let isEditable: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isUserInteractionEnabled = isEditable
        
        // pencil로만 그려지게 설정 
        if #available(iOS 14.0, *) {
              canvas.drawingPolicy = .pencilOnly
          }
        
        DispatchQueue.main.async {
            guard let window = canvas.window,
                  let toolPicker = PKToolPicker.shared(for: window) else {
                return
            }
            toolPicker.addObserver(canvas)
            toolPicker.setVisible(true, forFirstResponder: canvas)
            canvas.becomeFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isEditable
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        if !isEditable, let window = uiView.window,
           let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(false, forFirstResponder: uiView)
            toolPicker.removeObserver(uiView)
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

