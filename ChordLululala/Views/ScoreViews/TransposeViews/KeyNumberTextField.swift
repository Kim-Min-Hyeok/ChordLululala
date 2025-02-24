import SwiftUI


struct KeyNumberTextField: View {
    @Binding var text: String
    var body: some View {
        TextField("",text: $text)
            .keyboardType(.numberPad)
            .padding()
            .frame(width: 80, height: 40)
            .multilineTextAlignment(.center)
            .background(Color.init(#colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)))
            .cornerRadius(10)
    }
}


#Preview {
    KeyNumberTextField(text: .constant("C"))
}
