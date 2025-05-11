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

    /// .score 타입 ContentModel에 대해 ScoreDetail 엔티티를 생성or조회
    /// - 반환: 생성되거나 기존 데이터가 담긴 ScoreDetailModel (없으면 nil)
    func createScoreDetail(for content: ContentModel) -> AnyPublisher<ScoreDetailModel?, Never> {
        Future<ScoreDetailModel?, Never> { promise in
            guard content.type == .score else {
                promise(.success(nil))
                return
            }
            let req: NSFetchRequest<Content> = Content.fetchRequest()
            req.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
            do {
                guard let contentEntity = try self.context.fetch(req).first else {
                    print("⚠️ Content \(content.cid) 미발견")
                    promise(.success(nil))
                    return
                }
                // 이미 detail이 있으면 모델로 변환해 반환
                if let existing = contentEntity.scoreDetail {
                    promise(.success(ScoreDetailModel(entity: existing)))
                    return
                }
                // 새로 생성
                let detailEntity = ScoreDetail(context: self.context)
                detailEntity.s_did = UUID()
                detailEntity.key   = ""
                detailEntity.t_key = ""
                contentEntity.scoreDetail = detailEntity

                try self.context.save()
                promise(.success(ScoreDetailModel(entity: detailEntity)))
            } catch {
                print("❌ ScoreDetail 생성 오류:", error)
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
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
}
