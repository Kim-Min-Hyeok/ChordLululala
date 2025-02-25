import SwiftUI

struct PencilToolsView: View {
    @Binding  var isPencilActive: Bool
    @ObservedObject  var pencilToolsViewModel : PencilToolsViewModel
    
    init(isPencilActive: Binding<Bool>, pencilToolsViewModel: PencilToolsViewModel ) {
        self._isPencilActive = isPencilActive
        self.pencilToolsViewModel = pencilToolsViewModel
    }
    
    
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.1674384475, green: 0.1674384475, blue: 0.1674384475, alpha: 1)).ignoresSafeArea(.all).opacity(0.92)
            HStack{
                //펜
                Spacer()
                
                Button(action:{
                    if pencilToolsViewModel.selectedTool == .pencil {
                           
                           pencilToolsViewModel.closeToolbar()
                       } else {
                           pencilToolsViewModel.selectTool(.pencil)
                       }
                    
                    print("펜 클릭 ")
                }){
                    Image(systemName: "pencil")
                        .foregroundColor(pencilToolsViewModel.selectedTool == .pencil ? .blue : .white)
                }
                .padding(.trailing, 20)
                
                // 형광펜
                Button(action:{
                    if pencilToolsViewModel.selectedTool == .marker {
                           
                           pencilToolsViewModel.closeToolbar()
                       } else {
                           pencilToolsViewModel.selectTool(.marker)
                       }
                    print("형광펜 클릭 ")
                }){
                    Image(systemName: "highlighter")
                        .foregroundColor(pencilToolsViewModel.selectedTool == .marker ? .blue : .white)
                }
                .padding(.trailing, 20)
                
                // 지우개
                Button(action:{
                    if pencilToolsViewModel.selectedTool == .eraser {
                           
                           pencilToolsViewModel.closeToolbar()
                       } else {
                           pencilToolsViewModel.selectTool(.eraser)
                       }
                    print("지우개 클릭 ")
                }){
                    Image(systemName: "eraser")
                        .foregroundColor(pencilToolsViewModel.selectedTool == .eraser ? .blue : .white)
                }
                .padding(.trailing, 20)
                
                // 올가미=
                Button(action:{
                    if pencilToolsViewModel.selectedTool == .lasso {
                           
                           pencilToolsViewModel.closeToolbar()
                       } else {
                           pencilToolsViewModel.selectTool(.lasso)
                       }
                    print("올가미 클릭 ")
                }){
                    Image(systemName: "crop")
                        .foregroundColor(pencilToolsViewModel.selectedTool == .lasso ? .blue : .white)
                }
                .padding(.trailing, 20)
                
                // 뒤로 가기
                Button(action:{
                    pencilToolsViewModel.undo()
                    print("뒤 클릭 ")
                }){
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                // 앞으로 가기
                Button(action:{
                    pencilToolsViewModel.redo()
                    print("앞 클릭 ")
                }){
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                
                Spacer()
                
                // 취소 버튼
                Button(action:{
                    pencilToolsViewModel.closeToolbar()
                    isPencilActive.toggle()
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


//
//#Preview {
//    PencilToolsView()
//}
