

import SwiftUI

enum SettingsMenu {
    case pageLayout
    case pageRotation
}


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    @State private var isMemoActive: Bool = false
    @State private var isTransPose: Bool = false
    @State private var isSettingActive: Bool = false
    @State private var selectedMenu: SettingsMenu? = nil
    
    @StateObject private var gestureViewModel = MemoGestureViewModel()
    
    var body: some View {
        ZStack{
            VStack{
                if isTransPose {
                        TransposeHeaderView(isTransPose: $isTransPose)
                } else {
                    ScoreHeaderView(isPencilActive: $isPencilActive, isMemoActive: $isMemoActive, isSettingActive: $isSettingActive, isTransPose: $isTransPose)
                }
                
                Divider()
                
                if isPencilActive {
                        PencilToolsView(isPencilActive: $isPencilActive)
                        .padding(.top, -10)
                        .transition(.opacity)
                }
                
                ScoreDisplayView()
                Spacer()
            } // v
            
            
                

            
            
            if isMemoActive {
                MemoView(isMemoActive: $isMemoActive)
                    .offset(gestureViewModel.draggedOffset)
                    .gesture(gestureViewModel.drag)
                    .scaleEffect(gestureViewModel.magnifyBy)
                    .gesture(gestureViewModel.magnification)
            }
            
            
            if isSettingActive {
                VStack{
                    HStack{
                        Spacer()
                        SettingModalView(selectedMenu: $selectedMenu)
                            .padding(.trailing, 5)
                            .padding(.top, 55)
                    }
                    Spacer()
                }
            }
            
            //MARK: - body
            
            
            
            
            
            Spacer()
        } // z
        .animation(.easeInOut, value: isMemoActive)
        .animation(.easeInOut, value: isSettingActive)
        .animation(.easeInOut, value: isPencilActive)

    }
}


#Preview {
    ScoreView()
}



