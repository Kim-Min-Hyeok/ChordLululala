import SwiftUI

struct ScoreDoubleDisplayView: View {
    
    @StateObject var viewModel = MemoGestureViewModel()
    @StateObject var pageControlViewModel: PageControlViewModel
    
    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $pageControlViewModel.currentPage) {
                ForEach(Array(stride(from: 0, to: pageControlViewModel.images.count, by: 2)), id: \.self) { index in
                    HStack(spacing: 10){
                        Image(systemName: pageControlViewModel.images[index])
                            .resizable()
                            .scaledToFit()
                        
                        
                        if index + 1 < pageControlViewModel.images.count {
                            Image(systemName: pageControlViewModel.images[index + 1])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .background(Color.white)
                    .scaleEffect(viewModel.magnifyBy)
                    .gesture(viewModel.magnification)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            PageIndicatorView(
                currentPage: pageControlViewModel.displayPage,
                totalPages: pageControlViewModel.totalPages
            )
        }
    }
}


