
import SwiftUI

struct ScoreMainBodyView: View {
    @ObservedObject var pdfViewModel: ScorePDFViewModel
    @ObservedObject var playmodeViewModel: PlayModeViewModel
    @ObservedObject var pageNavViewModel: PageNavigationViewModel
    @ObservedObject var annotationVM: ScoreAnnotationViewModel
    @ObservedObject var isTransposing: IsTransposingViewModel
    
    var body: some View {
        ZStack {
            Color.primaryGray50
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $pageNavViewModel.currentPage) {
                ForEach(Array(pdfViewModel.images.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width *
                               (playmodeViewModel.isOn ? 1.0 : 0.9))
                        .shadow(radius: 4)
                        .padding(.vertical)
                        .tag(index)       // 페이지 태그 지정
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
                    .offset(x: -22, y: -25),
                alignment: .bottomTrailing
            )
            
            // 연주모드 실행시 투명한 버튼 뷰 띄우기
            if playmodeViewModel.isOn {
                PlayModeOverlayView(pageNavViewModel: pageNavViewModel)
            }
            
            /// 필기 모드 실행
            if annotationVM.isEditing {
                CanvasView(
                    drawing: $annotationVM.currentDrawing,
                    isEditable: true,
                    showToolbar: true
                )
                .ignoresSafeArea()
            } else {
                /// 필기 모드가 아닐 때도 필기 표시
                CanvasView(
                    drawing: Binding(
                        get: { annotationVM.currentDrawing },
                        set: { _ in }  // 편집 모드가 아닐 때는 변경 불가
                    ),
                    isEditable: false,
                    showToolbar: false
                )
                .ignoresSafeArea()
                .animation(.easeInOut, value: annotationVM.isEditing)
            }
            
            
        }
        .onChange(of: pageNavViewModel.currentPage){ newPage in
            annotationVM.save()
            annotationVM.load()
        }
        
        
        
    }
}
