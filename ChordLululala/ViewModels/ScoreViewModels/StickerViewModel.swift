import SwiftUI

class StickerViewModel: ObservableObject {
    @Published var draggedOffset = CGSize.zero
    @Published var accumulatedOffset = CGSize.zero
    @Published var magnifyBy = 1.0
    @Published var lastMagnifyBy = 1.0
    @Published var textFieldSize = CGSize(width: 80, height: 40) // 기본 크기

    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height

    // 이동 제스처
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let newOffset = self.accumulatedOffset + gesture.translation
                self.draggedOffset = newOffset
            }
            .onEnded { gesture in
                let finalOffset = self.accumulatedOffset + gesture.translation
                self.accumulatedOffset = finalOffset
                self.draggedOffset = self.accumulatedOffset
            }
    }

    // 확대/축소 제스처 (위/아래 드래그로 크기 조절)
    var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let newWidth = max(40, self.textFieldSize.width + gesture.translation.width)
                let newHeight = max(20, self.textFieldSize.height + gesture.translation.height)
                
                self.textFieldSize = CGSize(width: newWidth, height: newHeight)
            }
    }
}



