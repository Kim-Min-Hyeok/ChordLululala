
import SwiftUI

struct ScoreHeaderView: View {
    
    @State private var scoreTitle : String = "네잎 클로버"
    @Binding  var isPencilActive: Bool
    @Binding  var isMemoActive: Bool
    @Binding var isSettingActive: Bool
    @Binding var isTransPose : Bool
    @ObservedObject var pencilToolsViewModel : PencilToolsViewModel
    
    let file : [ContentModel]
    
    init(isPencilActive: Binding<Bool>, isMemoActive: Binding<Bool>, isSettingActive: Binding<Bool>, isTransPose: Binding<Bool>, pencilToolsViewModel: PencilToolsViewModel, file: [ContentModel]) {
        _isPencilActive = isPencilActive
        _isMemoActive = isMemoActive
        _isSettingActive = isSettingActive
        _isTransPose = isTransPose
        self.pencilToolsViewModel = pencilToolsViewModel
        self.file = file
    }
    
    var body: some View {
        
        HStack{
            // 뒤로가기
            Button(action:{
                print("뒤로 가기 클릭") // 기능 추가해야 함
            }){
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            
            // 전체 페이지
            Button(action:{
                print("전체 페이지 클릭")  // 기능 추가해야 함
            }){
               Text("전체 페이지")
                    .foregroundColor(Color.black)
                    .fontWeight(.semibold)
                
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(Color.black)
            }
            
            Spacer()
            
            // 제목
            Text(file[0].name)
                .fontWeight(.semibold)
            
            Spacer()
            
            // 펜슬
            Button(action:{
                isPencilActive.toggle()
                
                print("펜슬 기능 클릭") // 기능 추가해야함
            }){
                Image(systemName: isPencilActive ? "pencil.circle.fill" : "pencil") // 이미지 바꿔야 함
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            // 메모장
            Button(action:{
                isMemoActive.toggle()
                print("메모장 기능 클릭") // 기능 추가해야함
            }){
                Text("메모장")
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            // 키변환
            Button(action:{
                isTransPose.toggle()
                print("키변환 기능 클릭") // 기능 추가해야함
            }){
                Text("키변환")
                    .foregroundColor(Color.blue)
            }
            .padding(.trailing,10)
            
            // 설정
            Button(action:{
                isSettingActive.toggle()
                print("설정 기능 클릭") // 기능 추가해야함
            }){
                Image(systemName: "gear") // 이미지 바꿔야 함
                    .foregroundColor(Color.black)
            }
        }
        .frame(height: 83)
        .padding(.horizontal)
        
    }
}


