import SwiftUI

struct PageRotationView: View {
    @Binding var selectedMenu: SettingsMenu?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: { selectedMenu = nil }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("페이지 회전")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            
            Button(action: {}) {
                SettingsRowView(icon: "arrow.clockwise", title: "시계방향 90" , isChevron: false)
            }
            
            Button(action: {}) {
                SettingsRowView(icon: "arrow.counterclockwise", title: "반시계방향 90", isChevron: false)
            }
            
            Spacer()
        }
        .padding()
    }
}

