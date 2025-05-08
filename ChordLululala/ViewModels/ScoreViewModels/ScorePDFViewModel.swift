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
    
    
    /// 새 페이지 추가 기능
        func addPage(_ type: PageType) {
            // 기준 페이지 크기: 첫 페이지 크기 또는 기본값
            let pageSize = images.first?.size ?? CGSize(width: 800, height: 1100)
            let renderer = UIGraphicsImageRenderer(size: pageSize)
            let newImage = renderer.image { ctx in
                // 백지 배경
                UIColor.white.setFill()
                ctx.fill(CGRect(origin: .zero, size: pageSize))

                if type == .staff {
                    // "staff_template" 에셋이 있는 경우 사용
                    if let template = UIImage(named: "staff_template") {
                        template.draw(in: CGRect(origin: .zero, size: pageSize))
                    } else {
                        // 직접 오선 5개 그리기
                        ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                        ctx.cgContext.setLineWidth(1)
                        let spacing = pageSize.height / 6
                        for line in 1...5 {
                            let y = spacing * CGFloat(line)
                            ctx.cgContext.move(to: CGPoint(x: 0, y: y))
                            ctx.cgContext.addLine(to: CGPoint(x: pageSize.width, y: y))
                        }
                        ctx.cgContext.strokePath()
                    }
                }
            }

            DispatchQueue.main.async {
                self.images.append(newImage)
            }
        }
    
}
