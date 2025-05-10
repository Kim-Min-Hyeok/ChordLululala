
import SwiftUI

struct AddPageModalView: View {
    let onSelect: (PageType) -> Void
    @State private var selectedType: PageType? = nil
    @ObservedObject var pageAdditionVM: PageAdditionViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1)배경 카드
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primaryBaseWhite)
            
            // 2) 실제 콘텐츠
            VStack(spacing: 0) {
                // 2-1) 닫기 버튼 바
                HStack {
                    Spacer()
                    Button(action: {
                        pageAdditionVM.isSheetPresented = false
                    }) {
                        Text("닫기")
                            .textStyle(.headingSmMedium)
                    }
                    .foregroundColor(.primaryBlue600)
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(Color.primaryGray50)
                .cornerRadius(10)
                .padding(.bottom, 15)          // 닫기 바와 본문 사이 간격
                
                
                VStack(spacing: 0) {
                    Text("새 페이지 생성")
                        .textStyle(.headingXLSemiBold)
                        .foregroundColor(.primaryBaseBlack)
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
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(.primaryGray200)
                    .padding(.bottom, 14)
                
                
                Button(action: {
                    if let type = selectedType {
                        onSelect(type)
                        pageAdditionVM.isSheetPresented = false
                    }
                }) {
                    Text("생성하기")
                        .textStyle(.headingLgSemiBold)
                        .foregroundColor(
                            selectedType != nil
                            ? Color.primaryBlue600
                            : Color.primaryGray300
                        )
                }
                .disabled(selectedType == nil)
                .padding(.bottom, 13)
            }
        }
        .frame(width: 321, height: 395) // 전체 카드 크기
        .shadow(color: Color.primaryBaseBlack.opacity(0.25), radius: 30)
    }
}

