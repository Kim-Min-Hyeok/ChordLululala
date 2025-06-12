//
//  ScoreDetailManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation
import CoreData
import Combine

final class ScoreDetailManager {
    static let shared = ScoreDetailManager()
    private let context = CoreDataManager.shared.context
    
    func createScoreDetail(for content: Content) -> AnyPublisher<ScoreDetail, Never> {
        Future<ScoreDetail, Never> { [weak self] promise in
            guard let self = self else { return }   // self가 살아있을 때에만 실행

            // 기존 Detail 삭제
            if let existing = content.scoreDetail {
                self.context.delete(existing)
            }
            // 새 Detail 생성
            let detail = ScoreDetail(context: self.context)
            detail.key   = ""
            detail.t_key = ""
            content.scoreDetail = detail

            do {
                try self.context.save()
                promise(.success(detail))
            } catch {
                print("❌ ScoreDetail 생성 오류:", error)
                promise(.success(detail))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchDetail(for content: Content) -> ScoreDetail? {
            return content.scoreDetail
        }

        /// 기존 ScoreDetail 삭제 후, content에 새 ScoreDetail 엔티티를 생성하여 반환
        @discardableResult
        func cloneDetail(of original: ScoreDetail, to content: Content) -> ScoreDetail {
            // 기존 연결 삭제
            if let existing = content.scoreDetail {
                context.delete(existing)
            }
            // 새 엔티티 생성
            let detail = ScoreDetail(context: context)
            detail.key       = original.key
            detail.t_key     = original.t_key
            content.scoreDetail = detail

            try? context.save()
            return detail
        }
    
    func getContentURL(for detail: ScoreDetail) -> URL? {
        guard
            let relPath = detail.content?.path,
            !relPath.isEmpty,
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        return docs.appendingPathComponent(relPath)
    }
    
    @discardableResult
       func save(detailEntity: ScoreDetail) -> Bool {
           do {
               try context.save()
               print("✅ ScoreDetail 저장 완료")
               return true
           } catch {
               print("❌ ScoreDetail 저장 실패:", error)
               return false
           }
       }
}
