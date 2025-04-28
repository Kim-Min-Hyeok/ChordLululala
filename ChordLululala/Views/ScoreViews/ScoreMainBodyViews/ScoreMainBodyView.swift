
import SwiftUI

struct ScoreMainBodyView: View {
    @EnvironmentObject var viewModel: ScoreViewModel
    @State private var currentPage = 0      // 선택된 페이지 인덱스 바인딩
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "F3F4F6")
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                ForEach(Array(viewModel.pdfImages.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .padding(.vertical)
                        .tag(index)       // 페이지 태그 지정
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            // 만약 페이지 인디케이터(점)를 숨기고 싶다면
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            
            
            Button(action:{
                print("연주모드 토글")
            }) {
                Text("연주모드 OFF")
                    .frame(width: 131, height: 44)
                    .background(Color.primaryGray500)
                    .opacity(0.9)
                    .cornerRadius(8)
                    .foregroundColor(Color.primaryGray50)
            }
            .padding(16)
        }
    }
}
