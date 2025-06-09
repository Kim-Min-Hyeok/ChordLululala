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
    var sharedToolPicker: PKToolPicker // ✅ 공유 툴피커 주입

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput

        // ✅ 툴피커 등록
        sharedToolPicker.addObserver(canvasView)
        sharedToolPicker.addObserver(context.coordinator)

        DispatchQueue.main.async {
            canvasView.becomeFirstResponder()
            if isAnnotationMode {
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

        // ✅ 표시/숨김 전환
        if isAnnotationMode {
            sharedToolPicker.setVisible(true, forFirstResponder: canvasView)
        } else {
            sharedToolPicker.setVisible(false, forFirstResponder: canvasView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
