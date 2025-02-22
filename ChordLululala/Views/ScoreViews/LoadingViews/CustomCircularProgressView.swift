import SwiftUI

struct CustomCircularProgressView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4) // 배경 원
            
            Circle()
                .trim(from: 0.3, to: 0.9) // 부분적으로 잘라서 로딩 형태 만들기
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.5), Color.blue.opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(isAnimating ? 0 : 360))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .frame(width: 90, height: 90) // 크기 설정
        .onAppear {
            isAnimating = true
        }
    }
}
