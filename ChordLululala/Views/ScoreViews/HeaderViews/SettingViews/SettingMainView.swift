import SwiftUI

struct SettingsMainView: View {
    @Binding var selectedMenu: SettingsMenu?
    
    var body: some View {
        VStack(spacing: 10) {
            Text("설정")
                .font(.headline)
                .padding(.top)
            
            Divider()
            
            Button(action: { selectedMenu = .pageLayout }) {
                SettingsRowView(icon: "list.bullet.rectangle", title: "페이지 레이아웃", isChevron: true)
            }
            
            Button(action: { selectedMenu = .pageRotation }) {
                SettingsRowView(icon: "arrow.triangle.2.circlepath", title: "페이지 회전", isChevron: true)
            }
            
            Button(action: { selectedMenu = nil }) {
                SettingsRowView(icon: "xmark.circle", title: "페이지 지우기", isDestructive: true, isChevron: false)
            }
            
            Spacer()
        }
        .padding()
    }
}



