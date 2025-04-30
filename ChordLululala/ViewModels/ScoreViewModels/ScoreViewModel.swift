////
////  ScoreViewModel.swift
////  ChordLululala
////
////  Created by 김민준 on 4/5/25.
////
//
//import SwiftUI
//import Combine
//
//class ScoreViewModel: ObservableObject {
//    @Published var content: ContentModel? {
//        didSet{
//            headerViewModel.title = content?.name ?? ""
//        }
//    }
//    @Published var pdfImages: [UIImage] = []
//    @Published var currentPage: Int = 0
//    
//    let headerViewModel : ScoreHeaderViewModel
//    
//    
//    init(content: ContentModel?) {
//        print("📦 ScoreViewModel 초기화됨. 전달된 content: \(String(describing: content))")
//        self.content = content
//        self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
//        if let content = content {
////            loadPDF(for: content)
//        }
//    }
//    
//    //pdf를 이미지로 변환하는 함수
////    private func loadPDF(for content: ContentModel) {
////        guard let path = content.path,
////              let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
////            return
////        }
////        
////        let fileURL = documentsURL.appendingPathComponent(path)
////        
////        guard let pdfDocument = PDFDocument(url: fileURL) else {
////            print("PDF 로드 실패")
////            return
////        }
////        
////        // PDF의 각 페이지를 이미지로 변환
////        let pageCount = pdfDocument.pageCount
////        for i in 0..<pageCount {
////            guard let page = pdfDocument.page(at: i) else { continue }
////            
////            let pageRect = page.bounds(for: .mediaBox)
////            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
////            let image = renderer.image { context in
////                UIColor.white.set()
////                context.fill(pageRect)
////                
////                context.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
////                context.cgContext.scaleBy(x: 1.0, y: -1.0)
////                
////                page.draw(with: .mediaBox, to: context.cgContext)
////            }
////            
////            DispatchQueue.main.async {
////                self.pdfImages.append(image)
////            }
////        }
////    }
//}
//


import Combine
import SwiftUI

final class ScoreViewModel: ObservableObject{
    
    @Published var content: ContentModel?
    
    let headerViewModel: ScoreHeaderViewModel
    let pdfViewModel: ScorePDFViewModel

    // 현재 페이지 인덱스
    @Published var currentPage: Int = 0

    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel?) {
            // 1) 하위 VM 초기화
            self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
            self.pdfViewModel    = ScorePDFViewModel()
            
            // 2) Combine 파이프라인 설정
            // content.name → headerViewModel.title
            $content
                .compactMap { $0?.name }         // nil 무시
                .removeDuplicates()              // 중복 방지
                .sink { [headerViewModel] name in
                    headerViewModel.title = name
                }
                .store(in: &cancellables)
            
            // content → pdfViewModel.updateContent(_:)
            $content
                .sink { [pdfViewModel] content in
                    pdfViewModel.updateContent(content)
                }
                .store(in: &cancellables)
            
            // 3) 초기 값 설정
            self.content = content
        }
}
