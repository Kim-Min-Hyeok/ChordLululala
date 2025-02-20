import SwiftUI

struct PencilToolsView: View {
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.1674384475, green: 0.1674384475, blue: 0.1674384475, alpha: 1)).ignoresSafeArea(.all).opacity(0.92)
            HStack{
                //펜
                Spacer()
                
                Button(action:{
                    print("펜 클릭 ")
                }){
                    Image(systemName: "pencil")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 형광펜
                Button(action:{
                    print("형광펜 클릭 ")
                }){
                    Image(systemName: "pencil")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 지우개
                Button(action:{
                    print("지우개 클릭 ")
                }){
                    Image(systemName: "eraser")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 올가미
                Button(action:{
                    print("올가미 클릭 ")
                }){
                    Image(systemName: "crop")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 뒤로 가기
                Button(action:{
                    print("뒤 클릭 ")
                }){
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 앞으로 가기
                Button(action:{
                    print("앞 클릭 ")
                }){
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                Spacer()
                
                // 취소 버튼
                Button(action:{
                    print("취소 ")
                }){
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 30)
            }
        }
        .frame(height: 50)
    }
}



#Preview {
    PencilToolsView()
}
