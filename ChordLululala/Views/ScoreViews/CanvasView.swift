//
//  CanvasView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/9/25.
//

import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var isAnnotationMode: Bool
    var sharedToolPicker: PKToolPicker
    var originalSize: CGSize
    var displaySize: CGSize
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView(frame: CGRect(origin: .zero, size: originalSize))
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .pencilOnly
        
        sharedToolPicker.addObserver(canvasView)
        sharedToolPicker.addObserver(context.coordinator)
        context.coordinator.canvasView = canvasView
        
        DispatchQueue.main.async {
            if isAnnotationMode {
                canvasView.becomeFirstResponder()
                sharedToolPicker.setVisible(true, forFirstResponder: canvasView)
                sharedToolPicker.selectedTool = canvasView.tool
            }
        }
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if canvasView.drawing != drawing {
            canvasView.drawing = drawing
        }
        
        if isAnnotationMode {
            sharedToolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        } else {
            sharedToolPicker.setVisible(false, forFirstResponder: canvasView)
            canvasView.resignFirstResponder()
        }
        
        let scaleX = displaySize.width  / originalSize.width
        let scaleY = displaySize.height / originalSize.height
        canvasView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        var parent: CanvasView
        
        weak var canvasView: PKCanvasView?
        
        init(_ parent: CanvasView) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleEndAnnotation),
                name: .endAnnotation,
                object: nil
            )
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
        
        @objc private func handleEndAnnotation() {
            canvasView?.resignFirstResponder()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

extension Notification.Name {
    static let endAnnotation = Notification.Name("endAnnotation")
}
