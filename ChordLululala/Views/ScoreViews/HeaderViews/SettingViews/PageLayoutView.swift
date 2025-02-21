import SwiftUI

struct PageLayoutView: View {
    @Binding var selectedMenu: SettingsMenu?
    @Binding var layout: ScoreLayout
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: { selectedMenu = nil }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("페이지 레이아웃")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            Button(action: {
                layout = .single
            }) {
                SettingsRowView(icon: "doc.text", title: "한 페이지 보기")
            }
            
            Button(action: {
                layout = .double
            }) {
                SettingsRowView(icon: "square.grid.2x2", title: "여러 페이지 보기")
            }
            
            Spacer()
        }
        .padding()
    }
}

