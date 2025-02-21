

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
                if isPencilActive {
                    VStack {
                        PencilToolsView(isPencilActive: $isPencilActive)
                        Spacer()
                    }
                    .transition(.opacity)
                    
                }
                Spacer()
            }
            
            
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



