
import SwiftUI

struct AddPageModalView: View {
    @ObservedObject var viewModel: PageAdditionViewModel
    @State private var selectedType: PageType? = nil
    
    let onSelect: (PageType) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 닫기 버튼 헤더
            HStack {
                Spacer()
                Button(action: {
                    onClose()
                }) {
                    Text("닫기")
                        .textStyle(.headingSmMedium)
                        .foregroundColor(.primaryBlue600)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                }
            }
            .frame(height: 36)
            .background(Color.primaryGray50)
            .padding(.bottom, 15)
            
            VStack() {
                Text("새 페이지 생성")
                    .textStyle(.headingXLSemiBold)
                    .foregroundColor(.primaryBaseBlack)
                    .padding(.bottom,3)
                
                Text("원하는 타입의 페이지를 선택후 생성해주세요.")
                    .textStyle(.bodyTextLgRegular)
                    .foregroundColor(.primaryGray500)
            }
            .padding(.bottom, 28)
            
            
            HStack(spacing: 33) {
                PageOptionView(
                    type: .blank,
                    isSelected: selectedType == .blank,
                    title: "백지"
                ) { selectedType = .blank }
                PageOptionView(
                    type: .staff,
                    isSelected: selectedType == .staff,
                    title: "오선지"
                ) { selectedType = .staff }
            }
            .padding(.bottom, 22)
            
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primaryGray200)
            
            Button(action: {
                if let type = selectedType {
                    viewModel.addPage(type: type) { success in
                        if success {
                            onSelect(type)
                        } else {
                            onClose()
                        }
                    }
                }
            }) {
                HStack {
                    Text("생성하기")
                        .textStyle(.headingLgSemiBold)
                        .foregroundColor(
                            selectedType != nil
                            ? Color.primaryBlue600
                            : Color.primaryGray300
                        )
                    
                }
                .padding(.vertical, 13)
            }
            .disabled(selectedType == nil)
            
        }
        .frame(width: 321, alignment: .top) // 전체 카드 크기
        .background(Color.primaryBaseWhite)
        .cornerRadius(10)
        .shadow(color: Color.primaryBaseBlack.opacity(0.25), radius: 30)
    }
}

