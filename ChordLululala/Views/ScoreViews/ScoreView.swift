

import SwiftUI

struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: Content) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        ZStack{
            VStack{
                /// 악보 헤더부분
                if !viewModel.isPlayMode {
                    ScoreHeaderView(
                        file: viewModel.content,
                        presentSetlistOverViewModal: {
                            viewModel.isSetlistOverViewModalView = true
                        },
                        toggleAnnotationMode: {
                            viewModel.isAnnotationMode.toggle()
                        },
                        presentAddPageModal: {
                            viewModel.isAdditionModalView = true
                        },
                        presentOverViewModal: {
                            viewModel.isOverViewModalView = true
                        },
                        toggleSettingViewModal: {
                            viewModel.isSettingModalView.toggle()
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    // 슬라이드 인아웃 + 페이드 효과
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
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isAdditionModalView = false
                        }
                    
                    AddPageModalView(
                        viewModel: viewModel.pageAdditionViewModel,
                        onSelect: { type in
                            if viewModel.addPage(at: viewModel.currentPage, type: type) {
                                viewModel.isAdditionModalView = false
                            }
                        },
                        onClose: {
                            viewModel.isAdditionModalView = false
                        }
                    )
                    .zIndex(1)
                }
                .zIndex(1)
            }
            if viewModel.isOverViewModalView {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isOverViewModalView = false
                        }
                    
                    ScorePageOverView(
                        viewModel: viewModel.scorePageOverViewModel,
                        pages: viewModel.pages,
                        rotations: viewModel.rotations,
                        onClose: {
                            viewModel.isOverViewModalView = false
                        },
                        deletePage: { index in
                            viewModel.deletePage(at: index)
                        },
                        duplicatePage: { index in
                            viewModel.duplicatePage(at: index)
                        },
                        addImage: {
                            
                        },
                        addFile: {
                            
                        },
                        addBlank: {
                                viewModel.addPage(at: viewModel.pages.count-1, type: .blank)
                        },
                        addStaff: {
                                viewModel.addPage(at: viewModel.pages.count-1, type: .staff)
                        }
                    )
                    .zIndex(1)
                }
                .zIndex(1)
            }
            if viewModel.isSettingModalView {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isSettingModalView = false
                        }
                    ScoreSettingView(
                        deletePage: {
                            DispatchQueue.main.async {
                                viewModel.deletePage(at: viewModel.currentPage)
                                viewModel.isSettingModalView = false
                            }
                        },
                        showSinglePage: {
                            viewModel.isSinglePageMode = true
                            viewModel.isSettingModalView = false
                        },
                        showMultiPages: {
                            viewModel.isSinglePageMode = false
                            viewModel.isSettingModalView = false
                        },
                        rotateWithClockwise: {
                            DispatchQueue.main.async {
                                viewModel.rotatePage(clockwise: true)
                                viewModel.isSettingModalView = false
                            }
                        },
                        rotateWithCounterClockwise: {
                            DispatchQueue.main.async {
                                viewModel.rotatePage(clockwise: false)
                                viewModel.isSettingModalView = false
                            }
                        }
                    )
                    .padding(.top, 100)
                    .padding(.trailing, 26)
                }
            }
            if viewModel.isSetlistOverViewModalView {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isSetlistOverViewModalView = false
                        }
                    
                    ScoreSetlistOverView(
                        viewModel: viewModel.scoreSetlistOverViewModel
                    )
                }
            }
        }
        .onChange(of: viewModel.isAnnotationMode) {
            if !viewModel.isAnnotationMode {
                NotificationCenter.default.post(name: .endAnnotation, object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.saveAnnotations()
                }
            }
        }
        .onDisappear {
            viewModel.saveAnnotations()
        }
        .environmentObject(viewModel)
        .navigationBarHidden(true)
    }
}
