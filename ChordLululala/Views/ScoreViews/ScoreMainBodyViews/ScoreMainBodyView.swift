//
import SwiftUI

struct ScoreMainBodyView: View {
    @EnvironmentObject var pdfViewModel: ScorePDFViewModel
    @ObservedObject var playmodeViewModel: PlayModeViewModel
    @ObservedObject var pageNavViewModel: PageNavigationViewModel
    @ObservedObject var annotationVM: ScoreAnnotationViewModel
    @ObservedObject var isTransposing: IsTransposingViewModel
    @EnvironmentObject var settingVM: ScoreSettingViewModel
    @EnvironmentObject var overViewVM : ScorePageOverViewModel
    @EnvironmentObject var zoomVM : ImageZoomViewModel
    
    /// 한 페이지 모드면 [[img]], 두 페이지 모드면 [[img1, img2], [img3, img4], …]
    private var pages: [[UIImage]] {
        let imgs = pdfViewModel.images
        if settingVM.isSinglePage {
            return imgs.map { [$0] }
        } else {
            return stride(from: 0, to: imgs.count, by: 2).map { start in
                let end = min(start + 2, imgs.count)
                return Array(imgs[start..<end])
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.primaryGray50
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $pageNavViewModel.currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { pageIndex, pageImgs in
                    HStack(spacing: 12) {
                        ForEach(pageImgs, id: \.self) { uiImage in
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(zoomVM.scale)
                                    .offset(zoomVM.offset)
                                    .frame(
                                        width: UIScreen.main.bounds.width *
                                        CGFloat(
                                            settingVM.isSinglePage
                                            ? (playmodeViewModel.isOn ? 1.0 : 0.9)
                                            : (playmodeViewModel.isOn ? 0.5 : 0.45)
                                        )
                                    )
                                    .shadow(radius: 4)
                                    .padding(.vertical)
                                    .gesture(
                                        SimultaneousGesture(
                                            MagnificationGesture()
                                                .onChanged(zoomVM.onPinchChanged)
                                                .onEnded(zoomVM.onPinchEnded),
                                            DragGesture()
                                                .onChanged(zoomVM.onDragChanged)
                                                .onEnded(zoomVM.onDragEnded)
                                        )
                                    )
                                    .onTapGesture(count: 2) {
                                        withAnimation(.easeInOut) {
                                            zoomVM.reset()
                                        }
                                    }
                                
                                
                                
                                
                                /// 필기 모드 실행
                                if annotationVM.isEditing {
                                    CanvasView(
                                        drawing: $annotationVM.currentDrawing,
                                        isEditable: true,
                                        showToolbar: true
                                    )
                                    .frame(
                                        width: UIScreen.main.bounds.width *
                                        CGFloat(
                                            settingVM.isSinglePage
                                            ? (playmodeViewModel.isOn ? 1.0 : 0.9)
                                            : (playmodeViewModel.isOn ? 0.5 : 0.45)
                                        )
                                    )
                                    .scaleEffect(zoomVM.scale)
                                    .offset(zoomVM.offset)
                                    /// 필기모드 실행 중에도 화면 넘기기 위한 코드
                                    .allowsHitTesting(true)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onEnded{ gesture in
                                                let threshold: CGFloat = 50
                                                if gesture.translation.width > threshold{
                                                    // 왼쪽으로 넘길때
                                                    if pageNavViewModel.currentPage > 0 {
                                                        pageNavViewModel.currentPage -= 1
                                                    }
                                                } else if gesture.translation.width < -threshold {
                                                    // 오른쪽으로 넘길떄
                                                    if pageNavViewModel.currentPage < pdfViewModel.images.count - 1 {
                                                        pageNavViewModel.currentPage += 1
                                                    }
                                                }
                                                
                                            }
                                    )
                                    
                                } else {
                                    /// 필기 모드가 아닐 때도 필기 표시
                                    CanvasView(
                                        drawing: Binding(
                                            get: { annotationVM.currentDrawing },
                                            set: { _ in }  // 편집 모드가 아닐 때는 변경 불가
                                        ),
                                        isEditable: false,
                                        showToolbar: false
                                    ) .frame(
                                        width: UIScreen.main.bounds.width *
                                        CGFloat(
                                            settingVM.isSinglePage
                                            ? (playmodeViewModel.isOn ? 1.0 : 0.9)
                                            : (playmodeViewModel.isOn ? 0.5 : 0.45)
                                        )
                                    )
                                    .scaleEffect(zoomVM.scale)
                                    .offset(zoomVM.offset)
                                    .animation(.easeInOut, value: annotationVM.isEditing)
                                }
                            }
                        }
                    }
                    .tag(pageIndex)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .overlay(
                
                /// 페이지 인디케이터
                PageIndicatorView(
                    current: pageNavViewModel.currentPage + 1,
                    total: pdfViewModel.images.count
                )
                .offset(x: 22, y: -26),
                alignment: .bottomLeading
            )
            .overlay(
                
                /// 연주모드 버튼
                Button(action:{
                    withAnimation(.easeInOut) {
                        playmodeViewModel.toggle()
                    }
                    
                }) {
                    // 연주모드일때 OFF 뜨고, 일반모드일 떄 메세지
                    if(playmodeViewModel.isOn){
                        Text("연주 모드 ON")
                            .textStyle(.headingLgMedium)
                            .frame(width: 131,height: 44)
                            .background(Color.primaryGray800)
                            .opacity(0.9)
                            .cornerRadius(8)
                            .foregroundColor(Color.primaryGray50)
                    } else {
                        HStack(spacing: 3){
                            Image("playmode_lock")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("OFF")
                                .textStyle(.headingLgMedium)
                        }
                        .frame(width: 79,height: 37)
                        .background(Color.primaryGray900)
                        .foregroundColor(Color.primaryGray50)
                        .opacity(0.9)
                        .cornerRadius(32)
                    }
                    
                    
                    
                }
                    .offset(
                        x: playmodeViewModel.isOn ?  -22 : -16,
                        y: playmodeViewModel.isOn ? -25 : -30),
                alignment: .bottomTrailing
            )
            
            // 연주모드 실행시 투명한 버튼 뷰 띄우기
            if playmodeViewModel.isOn {
                PlayModeOverlayView(pageNavViewModel: pageNavViewModel)
            }
            
            
        }
        .overlay(alignment: .topTrailing){
            /// 설정 버튼 눌렀을 때 모달 표시
            if (settingVM.isSetting) {
                ScoreSettingView()
                    .padding(.top,6)
                    .padding(.trailing, 26)
            }
        }
        
        
        .onChange(of: pageNavViewModel.currentPage){ newPage in
            if newPage < annotationVM.pageModels.count {
                let pageModel = annotationVM.pageModels[newPage]
                annotationVM.switchToPage(pageId: pageModel.s_pid)
            }
        }
        .onDisappear {
            if let currentPageModel = annotationVM.pageModels.first(where: {$0.s_pid == annotationVM.currentPageId}){
                annotationVM.save(for: currentPageModel)
            }
        }
        
        
    }
}
