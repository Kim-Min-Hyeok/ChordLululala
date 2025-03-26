

import SwiftUI

enum SettingsMenu {
    case pageLayout
    case pageRotation
}

enum ScoreLayout {
    case single
    case double
}


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    @State private var isMemoActive: Bool = false
    @State private var isTransPose: Bool = false
    @State private var isSettingActive: Bool = false
    @State private var selectedMenu: SettingsMenu? = nil
    @State private var currentLayout: ScoreLayout = .single
    
    @StateObject  var pageControlViewModel : PageControlViewModel
    @StateObject private var gestureViewModel = MemoGestureViewModel()
    @StateObject private var pencilToolsViewModel: PencilToolsViewModel
    
    let file: [ContentModel]
    
    init(file: [ContentModel]){
        self.file = file
        
        let pageControlVM = PageControlViewModel(images: ["pencil", "square.and.arrow.up.circle.fill", "figure.walk", "sun.min", "sunrise"])
        self._pageControlViewModel = StateObject(wrappedValue: pageControlVM)
        self._pencilToolsViewModel = StateObject(wrappedValue: PencilToolsViewModel(pageCount: pageControlVM.images.count))
    }
    
    var body: some View {
        ZStack{
            VStack{
                if isTransPose {
                    TransposeHeaderView(isTransPose: $isTransPose)
                } else {
                    ScoreHeaderView(
                        isPencilActive: $isPencilActive,
                        isMemoActive: $isMemoActive,
                        isSettingActive: $isSettingActive,
                        isTransPose: $isTransPose,
                        
                        pencilToolsViewModel: pencilToolsViewModel,
                        file: file
                    )
                }
                
                Divider()
                
                if isPencilActive {
                    PencilToolsView(
                        isPencilActive: $isPencilActive,
                        pencilToolsViewModel: pencilToolsViewModel
                    )
                    .padding(.top, -10)
                    .transition(.opacity)
                }
                
                //MARK: - 악보 이미지 뷰
                switch currentLayout {
                case .single:
                    ScoreDisplayView(
                        pageControlViewModel: pageControlViewModel,
                        pencilToolsViewModel: pencilToolsViewModel,
                        file: file
                    )
                case .double:
                    ScoreDoubleDisplayView(
                        pageControlViewModel: pageControlViewModel,
                        pencilToolsViewModel: pencilToolsViewModel
                    )
                }
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
                        SettingModalView(selectedMenu: $selectedMenu, layout: $currentLayout)
                            .padding(.trailing, 5)
                            .padding(.top, 55)
                    }
                    Spacer()
                }
            }
            
            
            Spacer()
        } // z
        .onChange(of: currentLayout) { newLayout in
            pageControlViewModel.layout = newLayout
        }
        .navigationBarHidden(true)
        .animation(.easeInOut, value: isMemoActive)
        .animation(.easeInOut, value: isSettingActive)
        .animation(.easeInOut, value: isPencilActive)
        
    }
}




//#Preview {
//    ScoreView()
//}



