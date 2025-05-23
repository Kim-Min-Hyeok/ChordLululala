

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel?) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        ZStack{
            VStack{
                /// 악보 헤더부분
                if !viewModel.playmodeViewModel.isOn {
                    ScoreHeaderView(viewModel: viewModel.headerViewModel,
                                    annotationVM: viewModel.annotationViewModel,
                                    isTransposing: viewModel.isTransposingViewModel,
                                    pageAdditionVM: viewModel.pageAdditionViewModel,
                                    file: viewModel.content
                                    
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
            
            /// 페이지 추가 버튼 눌렀을때 뜨는 모달창
            if viewModel.pageAdditionViewModel.isSheetPresented  {
                Color.clear.ignoresSafeArea()
                ZStack{
                    AddPageModalView(
                        onSelect: { type in
                            viewModel.pageAdditionViewModel.addPage(type)
                        }, pageAdditionVM: viewModel.pageAdditionViewModel
                    )
                    
                }
            }
        }
        .environmentObject(viewModel.scoreSettingViewModel)
        .navigationBarHidden(true)
        
    }
    
}




