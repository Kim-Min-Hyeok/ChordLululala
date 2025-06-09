

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        ZStack{
            VStack{
                /// 악보 헤더부분
                if !viewModel.isPlayMode {
                    ScoreHeaderView(
                        file: viewModel.content,
                        toggleAnnotationMode: {
                            viewModel.isAnnotationMode.toggle()
                        },
                        presentAddPageModal: {
                            viewModel.isAdditionModalView = true
                        },
                        presentOverViewModal: {
                            viewModel.isOverViewModalView = true
                        },
                        presentSettingViewModal: {
                            viewModel.isSettingModalView = true
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity)) // 슬라이드 인아웃 + 페이드 효과
                }
                
                /// 악보 바디 뷰
                ScoreMainBodyView(
                    zoomViewModel: viewModel.imageZoomeViewModel,
                    chordBoxViewModel: viewModel.chordBoxViewModel,
                    annotationViewModel: viewModel.annotationViewModel
                )
            }
            
            /// 페이지 추가 버튼 눌렀을때 뜨는 모달창
            if viewModel.isAdditionModalView  {
                Color.clear.ignoresSafeArea()
                ZStack{
                    AddPageModalView(
                        viewModel: viewModel.pageAdditionViewModel,
                        onSelect: {
                            // TODO: 페이지 추가 시, 필요한 업데이트
                            viewModel.isAdditionModalView = false
                        },
                        onClose: {
                            viewModel.isAdditionModalView = false
                        }
                    )
                }
            }
        }
        .overlay {
            if(viewModel.scorePageOverViewModel.isPageOver) {
                ScorePageOverView(pages: viewModel.pages)
            }
        }
        .onDisappear {
            viewModel.saveAnnotations()
        }
        .environmentObject(viewModel)
        .navigationBarHidden(true)
    }
}




