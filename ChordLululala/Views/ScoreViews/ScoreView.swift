

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel?) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        
        VStack{
            /// 악보 헤더부분
            if !viewModel.playmodeViewModel.isOn {
                ScoreHeaderView(viewModel: viewModel.headerViewModel,
                                annotationVM: viewModel.annotationViewModel,
                                isTransposing: viewModel.isTransposingViewModel
                )
                .transition(.move(edge: .top).combined(with: .opacity)) // 슬라이드 인아웃 + 페이드 효과
            }
            
            /// 악보 바디 뷰
            ScoreMainBodyView(
                pdfViewModel: viewModel.pdfViewModel,
                playmodeViewModel: viewModel.playmodeViewModel,
                pageNavViewModel: viewModel.pageNavViewModel,
                annotationVM: viewModel.annotationViewModel,
                isTransposing: viewModel.isTransposingViewModel
            )
            
        }
        .navigationBarHidden(true)
        
    }
    
}




