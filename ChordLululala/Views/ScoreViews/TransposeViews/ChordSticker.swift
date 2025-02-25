import SwiftUI

struct ChordSticker: View {
    @StateObject var viewModel = StickerViewModel()
    @State var isVisible: Bool = true
    @State var chord: String = ""

    var body: some View {
        if isVisible {
            ZStack {
                // 텍스트 필드
                TextField("", text: $chord)
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(width: viewModel.textFieldSize.width, height: viewModel.textFieldSize.height)
                    .offset(viewModel.draggedOffset)
                    .gesture(viewModel.drag)

                // 닫기 버튼
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .background(Color.white.clipShape(Circle()))
                        .padding(4)
                }
                .offset(x: viewModel.draggedOffset.width - viewModel.textFieldSize.width / 2 - 15,
                        y: viewModel.draggedOffset.height - viewModel.textFieldSize.height / 2 - 15)

                // 크기 조절 버튼 (위/아래 드래그 시 크기 조절)
                Button(action: { }) {
                    Image(systemName: "arrowshape.left.arrowshape.right.fill")
                        .foregroundColor(.gray)
                        .background(Color.white.clipShape(Circle()))
                        .padding(4)
                }
                .offset(x: viewModel.draggedOffset.width + viewModel.textFieldSize.width / 2 + 15,
                        y: viewModel.draggedOffset.height + viewModel.textFieldSize.height / 2 + 15)
                .gesture(viewModel.resizeGesture)
            }
            .animation(.spring(), value: isVisible)
        }
    }
}

// 미리보기
#Preview {
    ChordSticker()
}

