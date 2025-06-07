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
    
    
    // pdf 불러오기
    private func loadPDF(for content: ContentModel){
        
        /// ScoreDetail 불러오기
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content),
              let path = content.path,
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            DispatchQueue.main.async { self.images = [] }
            return
        }
        
        let fileURL = docs.appendingPathComponent(path)
        
        guard let pdf = PDFDocument(url: fileURL) else {
            DispatchQueue.main.async { self.images = [] }
            return
        }
        
        /// ScorePageModel 불러오기
        let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
        print(#fileID,#function,#line, "\(pageModels)")
        
        var newImages: [UIImage] = []
        let pageSize = pdf.page(at: 0)?.bounds(for: .mediaBox).size ?? CGSize(width: 539, height: 697)
        
        for pageModel in pageModels {
            if pageModel.pageType == "pdf" { // 원본 pdf 파일인 경우
                
                guard let page = pdf.page(at: Int(pageModel.originalPageIndex ?? 0 )) else { continue }
                let bounds = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: bounds.size)
                let img = renderer.image { ctx in
                    UIColor.white.setFill()
                    ctx.fill(bounds)
                    ctx.cgContext.translateBy(x: 0, y: bounds.height)
                    ctx.cgContext.scaleBy(x: 1, y: -1)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                newImages.append(img)
            } else {                 // 백지 또는 오선지인 경우
                let renderer = UIGraphicsImageRenderer(size: pageSize)
                let img = renderer.image { ctx in
                    // 백지인 경우
                    UIColor.white.setFill()
                    ctx.fill(CGRect(origin: .zero, size: pageSize))
                    
                    // 오선지인 경우
                    if pageModel.pageType == "staff" {
                        if let template = UIImage(named: "staff_template"){
                            template.draw(in: CGRect(origin: .zero, size:   pageSize))
                        }
                    }
                }
                newImages.append(img)
            }
        }
        
        DispatchQueue.main.async {
            self.images = newImages
        }
        
    }
    
    
    
    
    /// 새 페이지 추가 기능 (맨 마지막에 추가)
    func addPage(_ type: PageType) {
        // 기준 페이지 크기: 첫 페이지 크기 또는 기본값
        let pageSize = images.first?.size ?? CGSize(width: 539, height: 697)
        let renderer = UIGraphicsImageRenderer(size: pageSize)
        let newImage = renderer.image { ctx in
            // 백지 배경
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: pageSize))
            
            if type == .staff {
                // "staff_template" 에셋이 있는 경우 사용
                if let template = UIImage(named: "staff_template") {
                    template.draw(in: CGRect(origin: .zero, size: pageSize))
                }
            }
        }
        
        DispatchQueue.main.async {
            self.images.append(newImage)
        }
    }
    
    /// 새 페이지 추가기능 ( 현재 페이지의 다음)
    func addPageNextIndex(_ type: PageType, afterIndex currentIndex: Int){
        
        let pageSize = images.first?.size ?? CGSize(width: 539, height: 697)
        let renderer = UIGraphicsImageRenderer(size: pageSize)
        let newImage = renderer.image { ctx in
            /// 백지
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: pageSize))
            
            /// 오선지
            if type == .staff {
                if let template = UIImage(named: "staff_template") {
                    template.draw(in: CGRect(origin: .zero, size: pageSize))
                }
            }
        }
        
        DispatchQueue.main.async {
            // 현재 페이지의 다음 위치에 삽입
            let insertIndex = min(currentIndex + 1, self.images.count)
            self.images.insert(newImage, at: insertIndex)
        }
    }
    
    
    //페이지 삭제 기능
    func removePage(at index: Int) {
        guard index >= 0 && index < images.count else {
            print("❌ 잘못된 인덱스로 페이지 삭제 시도: \(index)")
            return
        }
        
        DispatchQueue.main.async {
            self.images.remove(at: index)
            print("✅ PDF 페이지 삭제 완료: 인덱스 \(index)")
        }
    }
    
    
}




