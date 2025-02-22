

import SwiftUI



struct TransposeHeaderView: View {
    @Binding var isTransPose : Bool
    
    var body: some View {
        HStack {
            Button(action:{
                isTransPose.toggle()
                print("종료 누름")
            }){
                Text("종료")
                    .foregroundColor(Color.red)
            }
            
            Spacer()
            
            Text("키변환")
                .fontWeight(.semibold)
            
            Spacer()
            Button(action:{
                print(" 누름")
            }){
                Text("키변환 진행하기")
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.init(#colorLiteral(red: 0, green: 0.5694641471, blue: 1, alpha: 1)))
                    .cornerRadius(10)
            }
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
        
}



#Preview {
    TransposeHeaderView(isTransPose: .constant(false))
}
