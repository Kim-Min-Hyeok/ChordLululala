import SwiftUI



struct MemoView: View {
    @State var memoText : String = ""
    @Binding  var isMemoActive: Bool
    
    var body: some View {
        
        ZStack {
            Color.init(#colorLiteral(red: 1, green: 0.9647058845, blue: 0.5921568871, alpha: 1)).opacity(0.88).ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    // x 버
                    Spacer()
                    Button(action:{
                        print("x 버튼 클릭")
                        isMemoActive.toggle()
                    }){
                        Image(systemName: "x.circle")
                            .foregroundColor(Color.black)
                    }
                    .padding(.top)
                    .padding(.trailing)
                }
                
                // 텍스트 필드
                TextEditor(text: $memoText)
                    .scrollContentBackground(.hidden)
                    .background(Color.init(#colorLiteral(red: 1, green: 0.9647058845, blue: 0.5921568871, alpha: 1)))
                    .padding(.horizontal)
                    
                Spacer()
            }
            
        }
        .cornerRadius(10)
        .frame(width: 300,height: 300) // 추후 삭제하기
    }
}

//
//#Preview {
//    MemoView(memoText: "", isMemoActive: )
//}
