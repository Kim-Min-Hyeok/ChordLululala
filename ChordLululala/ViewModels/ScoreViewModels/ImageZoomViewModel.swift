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

    func onPinchChanged(_ value: CGFloat) {
        let newScale = lastScale * value
        scale = min(max(newScale, minScale), maxScale)
        if scale <= minScale {
            offset = .zero
            lastOffset = .zero
        }
    }

    func onPinchEnded(_ value: CGFloat) {
        lastScale = scale
        // 축소 상태라면 팬도 리셋
        if scale <= minScale {
            offset = .zero
            lastOffset = .zero
        }
    }

    func onDragChanged(_ value: DragGesture.Value) {
        // 확대된 상태일 때만 offset 변경
        guard scale > minScale else { return }
        offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
        )
    }

    func onDragEnded(_ value: DragGesture.Value) {
        // 확대된 상태일 때만 lastOffset 업데이트
        guard scale > minScale else {
            // 축소 상태로 돌아가면 항상 원점
            offset = .zero
            lastOffset = .zero
            return
        }
        lastOffset = offset
    }

    func reset() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}

