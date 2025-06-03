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
                for _ in 0..<pdf.pageCount {
                    let pageEntity = ScorePage(context: self.context)
                    pageEntity.s_pid = UUID()
                    pageEntity.rotation = 0
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
}
