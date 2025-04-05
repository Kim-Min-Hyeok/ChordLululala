import SwiftUI

struct ScoreMainBodyView: View {
    @EnvironmentObject var viewModel: ScoreViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 20) {
                ForEach(Array(viewModel.pdfImages.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9) // 현재 화면 기준으로 너비 조절
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .padding(.vertical)
                }
            }
            .padding(.horizontal)
        }
    }
}

