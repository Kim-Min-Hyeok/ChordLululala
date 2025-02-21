import SwiftUI

struct SettingsRowView: View {
    var icon: String
    var title: String
    var isDestructive: Bool = false
    var isChevron : Bool = false
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : .blue)
            Text(title)
                .foregroundColor(isDestructive ? .red : .black)
            Spacer()
            
            Image(systemName: "chevron.right")
                .opacity(isChevron ? 1 : 0)
        }
        .padding()
        .background(Color.white)
    }
}


#Preview {
    SettingsRowView(icon: "pencil", title: "페이지 레이아웃", isDestructive: false )
}
