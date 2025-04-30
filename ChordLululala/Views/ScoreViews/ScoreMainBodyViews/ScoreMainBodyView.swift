
import SwiftUI

struct ScoreMainBodyView: View {
    @ObservedObject var pdfViewModel: ScorePDFViewModel
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.primaryGray100
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                ForEach(Array(pdfViewModel.images.enumerated()), id: \.offset) { index, image in
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
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))

        
            
            
            
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
