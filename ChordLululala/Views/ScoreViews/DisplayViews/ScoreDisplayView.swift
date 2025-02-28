

import SwiftUI
import UIKit
import PencilKit

struct ScoreDisplayView : View {
    
    @StateObject var pageControlViewModel: PageControlViewModel
    @StateObject var memoViewModel = MemoGestureViewModel()
    @ObservedObject var pencilToolsViewModel : PencilToolsViewModel
    @StateObject private var pdfViewModel = PDFToImageViewModel()

    let file : [ContentModel]
    
    init(pageControlViewModel : PageControlViewModel, pencilToolsViewModel: PencilToolsViewModel, file: [ContentModel]){
        self._pageControlViewModel = StateObject(wrappedValue: pageControlViewModel)
        self.pencilToolsViewModel = pencilToolsViewModel
        self.file = file
    }
    
    private func loadImage(from path: String?) -> UIImage? {
        guard let path = path,
              FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    private func createImageView(for content: ContentModel, at index: Int) -> some View {
        let imagePath = content.path
        guard let imagePath = imagePath else { return  AnyView(Text("이미지 경로가 없음 ")) }
        
        print("\(imagePath)")
        pdfViewModel.loadPDF(from: imagePath)
        
        let uiImage = loadImage(from: content.path)
        
        return AnyView(
            ZStack {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                        .scaleEffect(memoViewModel.magnifyBy)
                        .gesture(memoViewModel.magnification)
                } else {
                    Text("이미지를 불러올 수 없습니다")
                    
                }
                
                PencilKitView(canvasView: pencilToolsViewModel.canvasViews[index])
                    .opacity(pencilToolsViewModel.isPencilActive ? 1 : 0)
            })
    }
    
    var body: some View {
        
        
        ZStack{
            Color.init(#colorLiteral(red: 0.6470588446, green: 0.6470588446, blue: 0.6470588446, alpha: 1)).edgesIgnoringSafeArea(.all)
            TabView(selection: $pageControlViewModel.currentPage ) {
                ForEach(Array(file.enumerated()), id: \.element.cid){ index, content in
                    createImageView(for: content, at: index)
                        .tag(index + 1)
                    
        
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .onChange(of: pageControlViewModel.currentPage){ newValue in
                pencilToolsViewModel.updateCurrentPage(newValue - 1 )
            }
            PageIndicatorView(
                currentPage: pageControlViewModel.displayPage ,
                totalPages: pageControlViewModel.totalPages
            )
            
        }
    }
}


