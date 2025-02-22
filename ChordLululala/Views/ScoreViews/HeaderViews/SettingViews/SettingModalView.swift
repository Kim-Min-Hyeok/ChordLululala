import SwiftUI

struct SettingModalView: View {
    @Binding var selectedMenu: SettingsMenu?
    @Binding var layout: ScoreLayout
    
    var body: some View {
        VStack {
            if selectedMenu == nil {
                SettingsMainView(selectedMenu: $selectedMenu)
            } else if selectedMenu == .pageLayout {
                PageLayoutView(selectedMenu: $selectedMenu , layout: $layout )
            } else if selectedMenu == .pageRotation {
                PageRotationView(selectedMenu: $selectedMenu)
            }
        }
        .frame(width: 280, height: 220)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .transition(.move(edge: .bottom))
    }
}

