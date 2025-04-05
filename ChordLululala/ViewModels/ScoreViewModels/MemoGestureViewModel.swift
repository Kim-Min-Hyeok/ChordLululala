import SwiftUI


class MemoGestureViewModel : ObservableObject {
    @Published var draggedOffset = CGSize.zero
    @Published var accumulatedOffset = CGSize.zero
    @Published var magnifyBy = 1.0
    @Published var lastMagnifyBy = 1.0
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var memoSize: CGSize = CGSize(width: 300, height: 300) 

    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let newOffset = self.accumulatedOffset + gesture.translation
                self.draggedOffset = self.clampedOffset(newOffset)
            }
            .onEnded { gesture in
                let finalOffset = self.accumulatedOffset + gesture.translation
                self.accumulatedOffset = self.clampedOffset(finalOffset)
                self.draggedOffset = self.accumulatedOffset
            }
    }
    
    var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                self.magnifyBy = self.lastMagnifyBy * value.magnification

            }
            .onEnded { value in
                self.lastMagnifyBy = self.magnifyBy
            }
      }
    
    
    private func clampedOffset(_ offset: CGSize) -> CGSize {
        let halfWidth = memoSize.width / 2
        let halfHeight = memoSize.height / 2


        let minX = -screenWidth / 2 + halfWidth
        let maxX = screenWidth / 2 - halfWidth
        let minY = -screenHeight / 2 + halfHeight
        let maxY = screenHeight / 2 - halfHeight

        return CGSize(
            width: min(max(offset.width, minX), maxX),
            height: min(max(offset.height, minY), maxY)
        )
    }

    
    
}


//MARK: -
extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
