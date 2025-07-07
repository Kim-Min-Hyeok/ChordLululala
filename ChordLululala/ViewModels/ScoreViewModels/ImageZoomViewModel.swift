//
//  ImageZoomViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/25/25.
//
import SwiftUI
import Combine
/// 화면 확대 축서소 기능 구현
final class ImageZoomViewModel: ObservableObject {
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    @Published var scale: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0
    
    @Published var offset: CGSize = .zero
    private var lastOffset: CGSize = .zero
    
    private let dragSensitivity: CGFloat = 2.5
    private var isDragging: Bool = false
    private var dragStartOffset: CGSize = .zero
    
    func onPinchChanged(_ value: CGFloat, center: CGPoint) {
        let newScale = lastScale * value
        let clampedScale = min(max(newScale, minScale), maxScale)
        
        let scaleChange = scale > 0 ? clampedScale / scale : 1.0
        let centerOffset = CGSize(
            width: (center.x - UIScreen.main.bounds.width / 2) * (1 - scaleChange),
            height: (center.y - UIScreen.main.bounds.height / 2) * (1 - scaleChange)
        )
        
        scale = clampedScale
        offset = CGSize(
            width: lastOffset.width + centerOffset.width,
            height: lastOffset.height + centerOffset.height
        )
        if scale <= minScale {
            offset = .zero
            lastOffset = .zero
        }
    }
    
    func onPinchEnded(_ value: CGFloat) {
        lastScale = scale
        lastOffset = offset
        if scale <= minScale {
            offset = .zero
            lastOffset = .zero
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        guard scale > minScale else { return }
        
        if !isDragging {
            dragStartOffset = offset
            isDragging = true
        }
        
        let sensitivity = dragSensitivity * scale
        
        let newOffset = CGSize(
            width: dragStartOffset.width + value.translation.width * sensitivity,
            height: dragStartOffset.height + value.translation.height * sensitivity
        )
        
        offset = clampOffset(newOffset)
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        guard scale > minScale else {
            offset = .zero
            lastOffset = .zero
            return
        }
        
        isDragging = false
        lastOffset = offset
    }
    
    private func clampOffset(_ newOffset: CGSize) -> CGSize {
        let maxOffsetX = UIScreen.main.bounds.width * (scale - 1) / 2
        let maxOffsetY = UIScreen.main.bounds.height * (scale - 1) / 2
        
        return CGSize(
            width: max(-maxOffsetX, min(maxOffsetX, newOffset.width)),
            height: max(-maxOffsetY, min(maxOffsetY, newOffset.height))
        )
    }
    
    func reset() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        isDragging = false
    }
}
