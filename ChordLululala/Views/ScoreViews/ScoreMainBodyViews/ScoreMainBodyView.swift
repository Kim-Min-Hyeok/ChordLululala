
import SwiftUI

struct ScoreMainBodyView: View {
    @ObservedObject var pdfViewModel: ScorePDFViewModel
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack {
            Color.primaryGray50
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                ForEach(Array(pdfViewModel.images.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .shadow(radius: 4)
                        .padding(.vertical)
                        .tag(index)       // 페이지 태그 지정
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .overlay(
                /// 페이지 인디케이터
                PageIndicatorView(
                    current: currentPage + 1,
                    total: pdfViewModel.images.count
                )
                .offset(x: 22, y: -26),
                alignment: .bottomLeading
            )
            .overlay(
                /// 연주모드 버튼
                Button(action:{
                    print("연주모드 토글") // TODO: 연주모드 기능 추가하기
                }) {
                    Text("연주모드 ON")
                        .frame(width: 131, height: 44)
                        .background(Color.primaryGray500)
                        .opacity(0.9)
                        .cornerRadius(8)
                        .foregroundColor(Color.primaryGray50)
                }
                .offset(x: -22, y: -25),
                alignment: .bottomTrailing
            )
            
        }
    }
}






