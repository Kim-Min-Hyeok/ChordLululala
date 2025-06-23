//
//  ScorePageManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import Foundation
import CoreData
import PDFKit
import Combine

final class ScorePageManager {
    static let shared = ScorePageManager()
    private var context: NSManagedObjectContext { CoreDataManager.shared.context }
    
    func createPages(
        for detail: ScoreDetail,
        fileURL: URL
    ) -> AnyPublisher<Void, Never> {
        
        return Future<Void, Never> { promise in
            // 이미 페이지가 있으면 스킵
            if let pages = detail.scorePages as? Set<ScorePage>, !pages.isEmpty {
                promise(.success(()))
                return
            }
            
            guard let pdf = PDFDocument(url: fileURL) else {
                print("❌ PDF 로드 실패:", fileURL)
                promise(.success(()))
                return
            }
            
            for idx in 0..<pdf.pageCount {
                let page = ScorePage(context: self.context)
                page.id                = page.id ?? UUID()
                page.pageType          = "pdf"
                page.originalPageIndex = Int16(idx)
                page.displayOrder      = Int16(idx)
                page.scoreDetail       = detail
            }
            
            do {
                try self.context.save()
            } catch {
                print("❌ ScorePage 생성 오류:", error)
            }
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPages(for detail: ScoreDetail) -> [ScorePage] {
        return (detail.scorePages as? Set<ScorePage>)?
            .sorted(by: { $0.displayOrder < $1.displayOrder }) ?? []
    }
    
    // 하나의 Content 내의 특정 페이지 복제
    @discardableResult
    func clonePage(_ original: ScorePage) -> ScorePage? {
        guard let detail = original.scoreDetail else {
            print("❌ duplicatePage: 연결된 ScoreDetail이 없습니다.")
            return nil
        }
        
        // 1) 같은 detail 아래 모든 페이지를 fetch & 정렬
        var pages = fetchPages(for: detail)
        pages.sort { $0.displayOrder < $1.displayOrder }
        
        // 2) 원본의 displayOrder, insertionOrder 계산
        let origOrder     = original.displayOrder
        let insertionOrder = origOrder + 1
        
        // 3) 원본 뒤 페이지들 순서 한 칸씩 뒤로 밀기
        for page in pages where page.displayOrder >= insertionOrder {
            page.displayOrder += 1
        }
        
        // 4) 새 엔티티 생성 & 속성 복사
        let newPage = ScorePage(context: context)
        newPage.id                = UUID()
        newPage.rotation          = original.rotation
        newPage.pageType          = original.pageType
        newPage.originalPageIndex = original.originalPageIndex
        newPage.displayOrder      = insertionOrder
        newPage.scoreDetail       = detail
        
        // 5) 한 번만 저장
        do {
            try context.save()
            print("✅ duplicatePage 완료: 원본 \(origOrder) 뒤에 \(insertionOrder)로 삽입")
            return newPage
        } catch {
            print("❌ duplicatePage 저장 실패:", error)
            return nil
        }
    }
    
    /// originalDetail의 페이지들을 newDetail로 복제하여 반환
    func clonePages(from originalPages: [ScorePage], to newDetail: ScoreDetail) -> [ScorePage] {
        var clones: [ScorePage] = []
        for page in originalPages {
            let np = ScorePage(context: context)
            np.pageType          = page.pageType
            np.originalPageIndex = page.originalPageIndex
            np.displayOrder      = page.displayOrder
            np.scoreDetail       = newDetail
            clones.append(np)
        }
        // 한 번만 save 해도 충분합니다
        do {
            try context.save()
        } catch {
            print("❌ 페이지 복제 저장 실패:", error)
        }
        return clones
    }
    
    /// 페이지 추가하기 기능 (백지 , 오선지)
    func addPage(
        for detailEntity: ScoreDetail,
        afterIndex currentIndex: Int,
        type: PageType
    ) -> ScorePage? {
        // 1) 기존 페이지들 fetch & 정렬
        var pages = fetchPages(for: detailEntity)
        pages.sort { $0.displayOrder < $1.displayOrder }
        
        // 2) 삽입 위치 계산
        let insertionOrder = Int16(currentIndex + 1)
        
        // 3) 이후 페이지들 시프트
        for page in pages where page.displayOrder >= insertionOrder {
            page.displayOrder += 1
        }
        
        // 4) 새 페이지 생성 & 설정
        let newPage = ScorePage(context: context)
        newPage.rotation          = 0
        newPage.pageType          = (type == .staff) ? "staff" : "blank"
        newPage.originalPageIndex = -1
        newPage.displayOrder      = insertionOrder
        newPage.scoreDetail       = detailEntity
        
        // 5) 저장
        do {
            try context.save()
            return newPage
        } catch {
            print("❌ 페이지 추가 실패:", error)
            return nil
        }
    }
    
    ///페이지 삭제 기능
    @discardableResult
    func deletePage(_ page: ScorePage) -> Bool {
        guard let detail = page.scoreDetail else {
            print("❌ deletePage: 연결된 ScoreDetail이 없습니다.")
            return false
        }
        
        // 삭제할 페이지의 순서를 기억해 두고
        let deletedOrder = page.displayOrder
        
        // Core Data에서 삭제
        context.delete(page)
        
        // 같은 detail 아래의 나머지 페이지들을 페치해서 순서 재조정
        let siblings = fetchPages(for: detail)
        for sibling in siblings where sibling.displayOrder > deletedOrder {
            sibling.displayOrder -= 1
        }
        
        // 한 번만 저장
        do {
            try context.save()
            print("✅ deletePage 완료 (order \(deletedOrder) 이후 페이지 당김)")
            return true
        } catch {
            print("❌ deletePage 저장 실패:", error)
            return false
        }
    }
    
    @discardableResult
    func rotatePage(_ page: ScorePage, clockwise: Bool) -> Bool {
        // rotation은 0…3 까지, 1은 +90°, 2는 180°, 3는 270°
        let delta: Int16 = clockwise ? 1 : -1
        var newRot = page.rotation + delta
        if newRot < 0 { newRot = 3 }
        newRot = newRot % 4
        page.rotation = newRot
        
        do {
            try context.save()
            print("✅ rotatePage 완료: rotation=\(newRot)")
            return true
        } catch {
            print("❌ rotatePage 저장 실패:", error)
            return false
        }
    }
    
    func updateScorePageDisplayOrder(_ pages: [ScorePage]) {
        for (i, page) in pages.enumerated() {
            page.displayOrder = Int16(i)
        }
        CoreDataManager.shared.saveContext()
    }
}
