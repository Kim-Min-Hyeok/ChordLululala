

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
                        isRecognized: $viewModel.currentScoreRecognized,
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
                        resetChords: {
                            viewModel.isChordResetModalView = true
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
                    annotationViewModel: viewModel.scoreAnnotationViewModel
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
                        onSelect: { type in
                            if viewModel.addPage(atFlatIndex: viewModel.selectedPageIndex, type: type) {
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
                        pages: viewModel.flatPages,
                        rotations: viewModel.flatRotations,
                        onClose: {
                            viewModel.isOverViewModalView = false
                        },
                        deletePage: { index in
                            viewModel.deletePage(atFlatIndex: index)
                        },
                        duplicatePage: { index in
                            viewModel.duplicatePage(atFlatIndex: index)
                        },
                        addImage: {
                            
                        },
                        addFile: {
                            
                        },
                        addBlank: {
                            viewModel.addPage(atFlatIndex: viewModel.flatPages.count-1, type: .blank)
                        },
                        addStaff: {
                            viewModel.addPage(atFlatIndex: viewModel.flatPages.count-1, type: .staff)
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
                                viewModel.deletePage(atFlatIndex: viewModel.selectedPageIndex)
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
                        rotateWithClockwise: { viewModel.rotatePage(atFlatIndex: viewModel.selectedPageIndex, clockwise: true)  ; viewModel.isSettingModalView = false
                        },
                        rotateWithCounterClockwise: { viewModel.rotatePage(atFlatIndex: viewModel.selectedPageIndex, clockwise: false) ; viewModel.isSettingModalView = false
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
                        viewModel: viewModel.scoreSetlistOverViewModel,
                        scores: $viewModel.scores,
                        moveScore: { indexSet, newOffset in
                            viewModel.moveScore(from: indexSet, to: newOffset)
                        },
                        deleteScore: { score in
                            viewModel.deleteScore(score)
                        },
                        addScores: { scores in                            viewModel.addScores(scores)
                        }
                    )
                }
            }
            if viewModel.isChordResetModalView {
                ZStack {
                    Color.black.opacity(0.4)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isChordResetModalView = false
                        }
                    
                    ChordResetModalView(
                        onDismiss: {
                            viewModel.isChordResetModalView = false
                            
                        },
                        onReset: {
                            viewModel.resetChords() {
                                viewModel.isChordResetModalView = false
                            }
                        }
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
