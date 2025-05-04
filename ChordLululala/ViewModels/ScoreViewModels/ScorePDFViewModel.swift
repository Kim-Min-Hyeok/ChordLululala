//
//  ScorePDFViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 4/30/25.
//

import SwiftUI
import PDFKit

/// PDF에서  UIImage 변환 전용 VM
final class ScorePDFViewModel : ObservableObject {
    @Published private(set) var images: [UIImage] = []
    
    //  content 변동시 호출
    func updateContent(_ content: ContentModel?){
        guard let content = content else {
            images = []
            return
        }
        loadPDF(for: content)
    }

    // pdf를 uiimage로 변환하는 함수
    private func loadPDF(for content: ContentModel) {
            DispatchQueue.global(qos: .userInitiated).async {
                var newImages: [UIImage] = []
                guard
                    let path = content.path,
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                    let pdf = PDFDocument(url: docs.appendingPathComponent(path))
                else {
                    DispatchQueue.main.async { self.images = [] }
                    return
                }
                
                for i in 0..<pdf.pageCount {
                    guard let page = pdf.page(at: i) else { continue }
                    let bounds = page.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: bounds.size)
                    let img = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(bounds)
                        ctx.cgContext.translateBy(x: 0, y: bounds.height)
                        ctx.cgContext.scaleBy(x: 1, y: -1)
                        page.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    newImages.append(img)
                }
                
                DispatchQueue.main.async { self.images = newImages }
            }
        } 
}
