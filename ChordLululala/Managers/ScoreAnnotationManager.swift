

import Foundation
import CoreData
import PencilKit

/// 악보 필기 관리하는 manager
final class ScoreAnnotationManager {
    static let shared = ScoreAnnotationManager()
    private let context = CoreDataManager.shared.context
    
    /// 저장하기
    @discardableResult
        func saveAnnotation(drawing: PKDrawing, for page: ScorePage) -> Bool {
            // 1) 기존 어노테이션 삭제
            if let existing = page.scoreAnnotations as? Set<ScoreAnnotation> {
                existing.forEach(context.delete)
            }

            // 2) 새 어노테이션 엔티티 생성
            let annot = ScoreAnnotation(context: context)
            annot.strokeData = drawing.dataRepresentation()
            // inverse 관계로 자동 추가됩니다
            annot.scorePage  = page

            // 3) 저장
            do {
                try context.save()
                return true
            } catch {
                print("❌ saveDrawing 실패:", error)
                return false
            }
        }
    
    func fetchAnnotations(for page: ScorePage) -> [ScoreAnnotation] {
        return Array(page.scoreAnnotations as? Set<ScoreAnnotation> ?? [])
    }

        /// originalAnnotations를 newPage로 복제
        func cloneAnnotations(_ originalAnnotations: [ScoreAnnotation], to newPage: ScorePage) {
            for annot in originalAnnotations {
                let na = ScoreAnnotation(context: context)
                na.strokeData = annot.strokeData
                na.scorePage  = newPage
            }
            try? context.save()
        }
}
