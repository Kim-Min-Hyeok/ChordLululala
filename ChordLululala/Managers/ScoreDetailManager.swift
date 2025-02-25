//
//  ScoreDetailManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import SwiftUI
import CoreData
import Combine

final class ScoreDetailManager {
    static let shared = ScoreDetailManager()
    private let context = CoreDataManager.shared.context
    
    // MARK: Create
    func createScoreDetail(for content: ContentModel, with scoreDetail: ScoreDetailModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // .score 타입인지 확인
            guard content.type == .score else {
                print("ScoreDetail은 .score 타입의 Content에만 추가할 수 있습니다.")
                promise(.success(()))
                return
            }
            
            // content.cid를 기준으로 Content 엔티티 조회
            let request: NSFetchRequest<Content> = Content.fetchRequest()
            request.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
            
            do {
                if let contentEntity = try self.context.fetch(request).first {
                    // 새로운 ScoreDetail 엔티티 생성 및 업데이트
                    let newScoreDetail = ScoreDetail(context: self.context)
                    newScoreDetail.update(from: scoreDetail)
                    
                    // 단일 관계이므로 기존에 addToScoreDetails가 아닌 scoreDetail에 할당
                    contentEntity.scoreDetail = newScoreDetail
                    
                    CoreDataManager.shared.saveContext()
                    print("ScoreDetail 추가 성공: \(contentEntity.name ?? "Unnamed")")
                } else {
                    print("Content 엔티티를 찾지 못했습니다. cid: \(content.cid)")
                }
            } catch {
                print("Content 엔티티 조회 실패: \(error)")
            }
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
