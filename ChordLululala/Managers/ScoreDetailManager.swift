//
//  ScoreDetailManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation
import CoreData
import Combine

/// ContentModel ↔ ScoreDetail(CoreData) 관리
final class ScoreDetailManager {
    static let shared = ScoreDetailManager()
    private let context = CoreDataManager.shared.context
    
    func createScoreDetail(for content: ContentModel) -> AnyPublisher<ScoreDetailModel, Never> {
        Future<ScoreDetailModel, Never> { promise in
            let req: NSFetchRequest<Content> = Content.fetchRequest()
            req.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
            
            do {
                guard let contentEntity = try self.context.fetch(req).first else {
                    fatalError("Content 엔티티 미발견: \(content.cid)")
                }
                
                // 이미 연결된 detail이 있으면 지운 뒤 새로 생성
                if let existing = contentEntity.scoreDetail {
                    self.context.delete(existing)
                }
                
                let detailEntity = ScoreDetail(context: self.context)
                detailEntity.s_did = UUID()
                detailEntity.key   = ""
                detailEntity.t_key = ""
                contentEntity.scoreDetail = detailEntity
                
                try self.context.save()
                promise(.success(ScoreDetailModel(entity: detailEntity)))
            } catch {
                print("❌ ScoreDetail 생성 오류:", error)
                // 실패해도 빈 모델 반환하기보다, 에러 로그 후 빈 detailModel은 막아야 합니다.
                // 여기서는 대체로 fallback으로 새 UUID로만듭니다.
                let fallback = ScoreDetailModel(s_did: UUID(), key: "", t_key: "", scorePages: [])
                promise(.success(fallback))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// ② ContentModel에 연결된 ScoreDetail이 이미 있으면 조회만 하고, 없으면 nil 반환
    func fetchScoreDetailModel(for content: ContentModel) -> ScoreDetailModel? {
        let req: NSFetchRequest<Content> = Content.fetchRequest()
        req.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
        guard
            let contentEntity = try? context.fetch(req).first,
            let detailEntity  = contentEntity.scoreDetail
        else {
            return nil
        }
        return ScoreDetailModel(entity: detailEntity)
    }
    
    func clone(from original: ScoreDetailModel, to content: ContentModel) -> ScoreDetailModel? {
            let req: NSFetchRequest<Content> = Content.fetchRequest()
            req.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
            guard let contentEntity = try? context.fetch(req).first else {
                print("❌ 복제 대상 Content 미발견")
                return nil
            }

            let newDetail = ScoreDetail(context: context)
            newDetail.s_did = UUID()
            newDetail.key = original.key
            newDetail.t_key = original.t_key
            newDetail.content = contentEntity
            contentEntity.scoreDetail = newDetail

            try? context.save()
            return ScoreDetailModel(entity: newDetail)
        }
    
    /// 주어진 ScoreDetailModel에 연결된 Content의 파일 URL 반환
    func getContentURL(for detail: ScoreDetailModel) -> URL? {
        // 1) Core Data에서 해당 ScoreDetail에 연결된 Content 엔티티를 찾고
        let req: NSFetchRequest<Content> = Content.fetchRequest()
        req.predicate = NSPredicate(format: "scoreDetail.s_did == %@", detail.s_did as CVarArg)
        guard
            let contentEntity = try? context.fetch(req).first,
            let relPath = contentEntity.path,
            !relPath.isEmpty
        else {
            return nil
        }
        
        // 2) 앱의 도큐먼트 디렉터리 URL을 얻어서
        guard let docsURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
        else {
            return nil
        }
        
        // 3) 도큐먼트 디렉터리 + 상대 경로를 결합해 절대 URL 생성
        return docsURL.appendingPathComponent(relPath)
    }
    
    func update(detailModel: ScoreDetailModel) {
        let req: NSFetchRequest<ScoreDetail> = ScoreDetail.fetchRequest()
        req.predicate = NSPredicate(format: "s_did == %@", detailModel.s_did as CVarArg)
        
        if let entity = try? context.fetch(req).first {
            entity.update(from: detailModel)
            CoreDataManager.shared.saveContext()
        }
    }
}
