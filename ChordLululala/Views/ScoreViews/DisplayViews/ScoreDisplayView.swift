

import SwiftUI
import UIKit
import PencilKit

struct ScoreDisplayView : View {
    
    @StateObject var pageControlViewModel: PageControlViewModel
    @StateObject var viewModel = MemoGestureViewModel()
    @StateObject var pencilToolsViewModel = PencilToolsViewModel()
    
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
                            .scaleEffect(viewModel.magnifyBy)
                            .gesture(viewModel.magnification)
                        
            
                        
                    
                    }
                    .tag(index + 1)
                    
                    
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            PageIndicatorView(
                currentPage: pageControlViewModel.displayPage ,
                totalPages: pageControlViewModel.totalPages
            )
            
        }
    }
}


