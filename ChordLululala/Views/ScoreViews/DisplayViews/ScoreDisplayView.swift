

import SwiftUI


struct ScoreDisplayView : View {
    
    @StateObject var viewModel = MemoGestureViewModel()
    @StateObject var pageControlViewModel: PageControlViewModel
    
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.6470588446, green: 0.6470588446, blue: 0.6470588446, alpha: 1)).edgesIgnoringSafeArea(.all)
            TabView(selection: $pageControlViewModel.currentPage ) {
                ForEach(Array(pageControlViewModel.images.enumerated()), id: \.element) { index, imageName in
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                        .scaleEffect(viewModel.magnifyBy)
                        .gesture(viewModel.magnification)
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
