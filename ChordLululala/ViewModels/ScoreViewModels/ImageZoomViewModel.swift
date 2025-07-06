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
    
    private let dragSensitivity: CGFloat = 1.0
    private var isDragging: Bool = false
    private var dragVelocity: CGSize = .zero
    private var lastDragTime: Date = Date()
    
    // 드래그시 관성
    private let inertiaDecay: CGFloat = 0.93 // 관성 감쇠율
    private let minVelocity: CGFloat = 80     // 최소 속도 (이하에서 멈춤)
    private var inertiaTimer: Timer?
    
    
    func onPinchChanged(_ value: CGFloat, center: CGPoint) {
        let newScale = lastScale * value
        let clampedScale = min(max(newScale, minScale), maxScale)
        
        let scaleChange = scale >  0 ?  clampedScale / scale : 1.0
        let centerOffset = CGSize(
            width: (center.x - UIScreen.main.bounds.width / 2) * (1 - scaleChange) ,
            height:(center.y - UIScreen.main.bounds.height / 2) * (1 - scaleChange)
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
        // 축소 상태라면 팬도 리셋
        if scale <= minScale {
            offset = .zero
            lastOffset = .zero
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        // 확대된 상태일 때만 offset 변경
        guard scale > minScale else { return }
        
        isDragging = true
        
        let currentTime = Date()
        let timeDelta = currentTime.timeIntervalSince(lastDragTime)
        
        if timeDelta > 0 {
            dragVelocity = CGSize(
                width: value.translation.width / CGFloat(timeDelta),
                height: value.translation.height / CGFloat(timeDelta)
            )
        }
        lastDragTime = currentTime
        
        
        
        let sensitivity = dragSensitivity * scale
        
        let newOffset = CGSize(
            width: lastOffset.width + value.translation.width * sensitivity,
            height: lastOffset.height + value.translation.height * sensitivity
        )
        let clampedOffset = clampOffset(newOffset)
        offset = clampedOffset
        
        
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        // 확대된 상태일 때만 lastOffset 업데이트
        guard scale > minScale else {
            // 축소 상태로 돌아가면 항상 원점
            offset = .zero
            lastOffset = .zero
            return
        }
        isDragging = false
        lastOffset = offset
        startInertia()
    }
    
    private func startInertia() {
        // 기존 타이머 정리
        inertiaTimer?.invalidate()
        
        // 관성이 충분히 클 때만 시작
        let velocityMagnitude = sqrt(dragVelocity.width * dragVelocity.width + dragVelocity.height * dragVelocity.height)
        
        guard velocityMagnitude > minVelocity else {
            // 속도가 작으면 즉시 멈춤
            applyBoundarySnap()
            return
        }
        
        // 관성 애니메이션 시작
        inertiaTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updateInertia()
        }
    }
    
    private func updateInertia() {
        guard !isDragging else {
            inertiaTimer?.invalidate()
            return
        }
        
        // 관성 적용
        let sensitivity = dragSensitivity * scale
        let newOffset = CGSize(
            width: offset.width + dragVelocity.width * sensitivity * 0.016, // 60fps
            height: offset.height + dragVelocity.height * sensitivity * 0.016
        )
        
        // 경계 체크
        let clampedOffset = clampOffset(newOffset)
        offset = clampedOffset
        
        // 속도 감쇠
        dragVelocity = CGSize(
            width: dragVelocity.width * inertiaDecay,
            height: dragVelocity.height * inertiaDecay
        )
        
        // 속도가 충분히 작아지면 멈춤
        let velocityMagnitude = sqrt(dragVelocity.width * dragVelocity.width + dragVelocity.height * dragVelocity.height)
        if velocityMagnitude < minVelocity {
            inertiaTimer?.invalidate()
            applyBoundarySnap()
        }
    }
    
    private func applyBoundarySnap() {
        // 경계에 가까우면 부드럽게 스냅
        withAnimation(.easeOut(duration: 0.3)) {
            offset = clampOffset(offset)
        }
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
        dragVelocity = .zero
        inertiaTimer?.invalidate()
    }
    
    deinit {
        inertiaTimer?.invalidate()
    }
}

