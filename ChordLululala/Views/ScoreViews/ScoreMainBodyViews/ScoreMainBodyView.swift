
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
                        Text(playmodeViewModel.isOn ? "OFF" : "연주모드 ON")
                            .frame(width: playmodeViewModel.isOn ? 55 : 131,
                                   height: 44)
                            .background(playmodeViewModel.isOn ? Color.init(hex: "#2563EB") : Color.primaryGray500)
                            .opacity(0.9)
                            .cornerRadius(8)
                            .foregroundColor(Color.primaryGray50)
                    }
                        .offset(x: -22, y: -25),
                    alignment: .bottomTrailing
                )
                
                // 연주모드 실행시 투명한 버튼 뷰 띄우기
                if playmodeViewModel.isOn {
                    PlayModeOverlayView(pageNavViewModel: pageNavViewModel)
                }
                
                // 주석 모드일때 띄우기
                if annotationVM.isEditing {
                    CanvasView(
                        drawing: $annotationVM.currentDrawing,
                        isEditable: true
                    )
                    .ignoresSafeArea()
                }
            }
            
        
        
    }
}
