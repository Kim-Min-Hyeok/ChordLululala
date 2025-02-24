import SwiftUI

struct ChordSticker: View {
    @State var chord : String = ""
    var body: some View {
        TextField("", text: $chord)
            .padding()
            .background(Color.init(#colorLiteral(red: 0.9499571919, green: 0.9500558972, blue: 0.953115046, alpha: 1)))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.init(#colorLiteral(red: 0.8894182444, green: 0.8894182444, blue: 0.8894182444, alpha: 1)), lineWidth: 1)
            )
            .frame(width: 80, height: 23)
        
    }
    
        
}


#Preview {
    ChordSticker()
}

