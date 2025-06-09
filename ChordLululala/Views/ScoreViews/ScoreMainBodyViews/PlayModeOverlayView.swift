import SwiftUI

///화면 이동할때 누르는 투명한 뷰
struct PlayModeOverlayView: View {
    
    let goToFirstPage: () -> Void
    let goToLastPage: () -> Void
    let goToPreviousPage: () -> Void
    let goToNextPage: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            let marginWidth = w * 0.2
            
            let topRatio: CGFloat = 0.2
            let bottomRatio: CGFloat = 0.65
            
            ZStack {
                // 위쪽 : 맨 앞으로 / 맨 뒤로
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // 좌상단: 맨 앞으로
                        Color.clear
                            .frame(width: marginWidth, height: h * topRatio)
                            .contentShape(Rectangle())
                            .onTapGesture { goToFirstPage() }
                        
                        Spacer()
                        
                        // 우상단: 맨 뒤로
                        Color.clear
                            .frame(width: marginWidth, height: h * topRatio)
                            .contentShape(Rectangle())
                            .onTapGesture { goToLastPage() }
                    }
                    Spacer()
                }
                // 아래쪽 : 이전 / 다음 페이지
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        // 좌중단: 이전
                        Color.clear
                            .frame(width: marginWidth, height: h * bottomRatio )
                            .contentShape(Rectangle())
                            .onTapGesture { goToPreviousPage() }
                        
                        Spacer()
                        
                        // 우중단: 다음
                        Color.clear
                            .frame(width: marginWidth, height: h * bottomRatio)
                            .contentShape(Rectangle())
                            .onTapGesture { goToNextPage() }
                    }
                    Spacer()
                }
                
            }
            .ignoresSafeArea()  // 안전영역까지 풀스크린
        }
    }
}

