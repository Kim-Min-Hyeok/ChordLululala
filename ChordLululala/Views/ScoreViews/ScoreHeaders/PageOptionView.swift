import SwiftUI


struct PageOptionView: View {
    let type : PageType
    let isSelected: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            
            VStack(spacing: 0) {
                Group {
                    switch type {
                    case .blank:
                        Image("blank_template")
                            .resizable()
                    case .staff:
                        Image("staff_mini_template")
                            .resizable()
                    }
                }
                .frame(width: 106, height: 134)
                .shadow(color: Color.primaryBaseBlack.opacity(0.15), radius: 4)
                .onTapGesture {
                    action()
                }
                .padding(.bottom,6)
                
                Text(title)
                    .textStyle(.bodyTextLgRegular)
                    .foregroundColor(Color.primaryGray500)
                    .padding(.bottom, 16)
                
                /// 체크버튼
                Image(isSelected ? "check_true" : "check_false")
                    .resizable()
                    .frame(width: 26, height: 26)
                
                
            }
        }
        .buttonStyle(PlainButtonStyle())
        
    }
}
