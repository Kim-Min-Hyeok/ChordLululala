import SwiftUI

struct ScoreDoubleDisplayView: View {
    
    @StateObject var viewModel = MemoGestureViewModel()
    @StateObject var pageControlViewModel: PageControlViewModel
    @ObservedObject private var pencilToolsViewModel: PencilToolsViewModel
    
    init(pageControlViewModel: PageControlViewModel, pencilToolsViewModel: PencilToolsViewModel) {
        self._pageControlViewModel = StateObject(wrappedValue: pageControlViewModel)
        self.pencilToolsViewModel = pencilToolsViewModel
    }
     
    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $pageControlViewModel.currentPage) {
                ForEach(Array(stride(from: 0, to: pageControlViewModel.images.count, by: 2)), id: \.self) { index in
                    ZStack {
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
                        
                        
                        HStack(spacing: 10) {
                            PencilKitView(canvasView: pencilToolsViewModel.canvasViews[index])
                                .opacity(pencilToolsViewModel.isPencilActive ? 1 : 0)
                            
                            if index + 1 < pencilToolsViewModel.canvasViews.count {
                                PencilKitView(canvasView: pencilToolsViewModel.canvasViews[index + 1])
                                    .opacity(pencilToolsViewModel.isPencilActive ? 1 : 0)
                            }
                        }
                    } // zstack
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .onChange(of: pageControlViewModel.currentPage){ newValue in
                pencilToolsViewModel.updateCurrentPage(newValue * 2 )
                
            }
            
            PageIndicatorView(
                currentPage: pageControlViewModel.displayPage,
                totalPages: pageControlViewModel.totalPages
            )
        }
    }
}


