

import SwiftUI
import UIKit
import PencilKit

struct ScoreDisplayView : View {
    
    @StateObject var pageControlViewModel: PageControlViewModel
    @StateObject var memoViewModel = MemoGestureViewModel()
    @ObservedObject var pencilToolsViewModel : PencilToolsViewModel
    
    init(pageControlViewModel : PageControlViewModel, pencilToolsViewModel: PencilToolsViewModel){
        self._pageControlViewModel = StateObject(wrappedValue: pageControlViewModel)
        self.pencilToolsViewModel = pencilToolsViewModel
    }
    
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.6470588446, green: 0.6470588446, blue: 0.6470588446, alpha: 1)).edgesIgnoringSafeArea(.all)
            TabView(selection: $pageControlViewModel.currentPage ) {
                ForEach(Array(pageControlViewModel.images.enumerated()), id: \.element) { index, imageName in
                    ZStack {
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .background(Color.white)
                            .scaleEffect(memoViewModel.magnifyBy)
                            .gesture(memoViewModel.magnification)
                        
            
                        
                        PencilKitView(canvasView: pencilToolsViewModel.canvasViews[index])
                            .opacity(pencilToolsViewModel.isPencilActive ? 1 : 0)

                    }
                    .tag(index + 1)
                    
                    
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .onChange(of: pageControlViewModel.currentPage){ newValue in
                pencilToolsViewModel.updateCurrentPage(newValue - 1 )
            }
            PageIndicatorView(
                currentPage: pageControlViewModel.displayPage ,
                totalPages: pageControlViewModel.totalPages
            )
            
        }
    }
}


