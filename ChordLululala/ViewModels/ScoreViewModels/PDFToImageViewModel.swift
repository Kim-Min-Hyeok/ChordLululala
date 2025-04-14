import SwiftUI
import PDFKit

class PDFToImageViewModel: ObservableObject {
    @Published var pdfImages: [UIImage] = []
    
    func loadPDF(from path: String?) {
        guard let path = path,
              FileManager.default.fileExists(atPath: path) else {
            print("PDF 경로가 없거나 파일이 존재하지 않습니다")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        guard let pdfDocument = PDFDocument(url: url) else {
            print("PDF 문서를 불러올 수 없습니다")
            return
        }
        
        pdfImages.removeAll()
        
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            
            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(pageRect)
                page.draw(with: .mediaBox, to: context.cgContext)
            }
            
            pdfImages.append(image)
        }
    }
    
    func getImage(at index: Int) -> UIImage? {
        guard index >= 0 && index < pdfImages.count else { return nil }
        return pdfImages[index]
    }
}
