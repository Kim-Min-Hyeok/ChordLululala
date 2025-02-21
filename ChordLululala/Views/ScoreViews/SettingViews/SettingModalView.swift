import SwiftUI


struct SettingModalView: View {
    var body: some View {
        VStack{
            Text("설정 뷰")
        }
        .frame(width: 280, height: 220)
        .cornerRadius(5)
        .shadow(radius: 5)
        .transition(.move(edge: .bottom))
    }
}
