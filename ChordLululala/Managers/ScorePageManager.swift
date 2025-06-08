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

/// ScoreDetailModel ↔ ScorePage(CoreData) 관리
final class ScorePageManager {
    static let shared = ScorePageManager()
    private let context = CoreDataManager.shared.context
    
    /// detailModel에 대해 PDF 페이지 수만큼 ScorePage 엔티티 생성
    func createPages(for detail: ScoreDetailModel, fileURL: URL) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            let req: NSFetchRequest<ScoreDetail> = ScoreDetail.fetchRequest()
            req.predicate = NSPredicate(format: "s_did == %@", detail.s_did as CVarArg)
            do {
                guard let detailEntity = try self.context.fetch(req).first else {
                    print("⚠️ ScoreDetail \(detail.s_did) 미발견")
                    promise(.success(()))
                    return
                }
                // 이미 페이지가 있으면 스킵
                if let pages = detailEntity.scorePages, pages.count > 0 {
                    promise(.success(()))
                    return
                }
                // PDF 로드 후 페이지 수만큼 생성
                guard let pdf = PDFDocument(url: fileURL) else {
                    print("❌ PDF 로드 실패:", fileURL)
                    promise(.success(()))
                    return
                }
                for i in 0..<pdf.pageCount {
                    let pageEntity = ScorePage(context: self.context)
                    pageEntity.s_pid = UUID()
                    pageEntity.rotation = 0
                    pageEntity.pageType = "pdf"
                    pageEntity.originalPageIndex = Int16(i)
                    pageEntity.displayOrder = Int16(i)
                    detailEntity.addToScorePages(pageEntity)
                    pageEntity.scoreDetail = detailEntity
                }
                try self.context.save()
                promise(.success(()))
            } catch {
                print("❌ ScorePage 생성 오류:", error)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPageEntities(for detail: ScoreDetailModel) -> [ScorePage] {
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "scoreDetail.s_did == %@", detail.s_did as CVarArg)
        req.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending:   true)]
        return (try? context.fetch(req)) ?? []
    }
    
    func fetchPageModels(for detail: ScoreDetailModel) -> [ScorePageModel] {
        fetchPageEntities(for: detail).map { ScorePageModel(entity: $0) }
    }
    
    func clone(from originalPages: [ScorePageModel], to detail: ScoreDetailModel) -> [ScorePageModel] {
        let req: NSFetchRequest<ScoreDetail> = ScoreDetail.fetchRequest()
        req.predicate = NSPredicate(format: "s_did == %@", detail.s_did as CVarArg)

        guard let detailEntity = try? context.fetch(req).first else {
            print("❌ 복사 대상 ScoreDetail 못찾음")
            return []
        }

        var result: [ScorePageModel] = []

        for page in originalPages {
            let newPage = ScorePage(context: context)
            newPage.s_pid = UUID()
            newPage.rotation = Int16(page.rotation)
            newPage.scoreDetail = detailEntity
            detailEntity.addToScorePages(newPage)
            result.append(ScorePageModel(entity: newPage))
        }

        try? context.save()
        return result
    }
    
    /// 페이지 추가하기 기능 (백지 , 오선지)
    func addPage(for detail: ScoreDetailModel, afterIndex currentIndex: Int, type: PageType) -> ScorePageModel?{
        
        
        let req: NSFetchRequest<ScoreDetail> = ScoreDetail.fetchRequest()
        req.predicate = NSPredicate(format: "s_did == %@", detail.s_did as CVarArg)
        
        print("💾 [ScorePageManager] ScoreDetail 조회 시작...")
        guard let detailEntity = try? context.fetch(req).first else {
            print(#fileID,#function,#line, "❌ ScoreDetail 엔티티를 찾을 수 없음")
            return nil
        }
        print("✅ [ScorePageManager] ScoreDetail 엔티티 발견")
        
        let existingPages = fetchPageEntities(for: detail)
        
        //새 페이지 엔티티 생성
        let pageEntity = ScorePage(context: context)
        pageEntity.s_pid = UUID()
        pageEntity.rotation = 0
        pageEntity.pageType = type == .staff ? "staff" : "blank"
        pageEntity.originalPageIndex = -1
        pageEntity.displayOrder = Int16(currentIndex + 1)
        pageEntity.scoreDetail = detailEntity
        detailEntity.addToScorePages(pageEntity)
        
        // 중간에 추가된 경우 이후 페이지 한칸씩 밀기
        for page in existingPages {
            if page.displayOrder > Int16(currentIndex) {
                page.displayOrder += 1
            }
        }
        
        do {
            
            try context.save()
            
            return ScorePageModel(entity: pageEntity)
        } catch {
            print(#fileID,#function,#line, "ScorePageManager 페이지 추가 저장 실패")
            print("❌ [ScorePageManager] 저장 실패 상세: \(error.localizedDescription)")
            print("❌ [ScorePageManager] 에러 정보: \(error)")
            return nil
        }
        
    }
    
    ///페이지 삭제 기능
    func deletePage(displayOrder: Int) -> Bool {
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", displayOrder as CVarArg)
        
        guard let pageEntity = try? context.fetch(req).first else {
            print(#fileID,#function,#line, "❌ ScoreDetail 엔티티를 찾을 수 없음")
            return false
        }
        
        // 페이지 삭제
        context.delete(pageEntity)
        
        do {
            try context.save()
            return true
        } catch {
            print(#fileID,#function,#line, "❌ ScorePageManager 삭제 실패")
            return false
        }
    }
    
}
