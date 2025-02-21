

import SwiftUI

enum SettingsMenu {
    case pageLayout
    case pageRotation
}


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    @State private var isMemoActive: Bool = false
    @State private var isSettingActive: Bool = false
    @State private var selectedMenu: SettingsMenu? = nil
    
    @StateObject private var gestureViewModel = MemoGestureViewModel()
    
    var body: some View {
        ZStack{
            
            VStack{
                ScoreHeaderView(isPencilActive: $isPencilActive, isMemoActive: $isMemoActive, isSettingActive: $isSettingActive)
                Divider()
                
                HStack{
                    Spacer()
                    if isSettingActive {
                        SettingModalView(selectedMenu: $selectedMenu)
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
}


#Preview {
    ScoreView()
}



