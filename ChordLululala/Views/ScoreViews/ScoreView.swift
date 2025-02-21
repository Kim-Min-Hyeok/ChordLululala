

import SwiftUI


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    @State private var isMemoActive: Bool = false
    @State private var isSettingActive: Bool = false
    
    @StateObject private var gestureViewModel = MemoGestureViewModel()

    var body: some View {
        
        VStack{
            ScoreHeaderView(isPencilActive: $isPencilActive, isMemoActive: $isMemoActive, isSettingActive: $isSettingActive)
            Divider()
            
            HStack{
                Spacer()
                if isSettingActive {
                    SettingModalView()
                        .background(Color.yellow)
                        .padding(.trailing, 5)
                }
                
            }
            
            if isPencilActive {
                PencilToolsView(isPencilActive: $isPencilActive)
            }
            Spacer()
            
            if isMemoActive {
                MemoView(isMemoActive: $isMemoActive)
                .offset(gestureViewModel.draggedOffset)
                .gesture(gestureViewModel.drag)
                .scaleEffect(gestureViewModel.magnifyBy)
                .gesture(gestureViewModel.magnification)
            }
            
            Spacer()
            
            
            
            
            
        }
        
    }
}


#Preview {
    ScoreView()
}



