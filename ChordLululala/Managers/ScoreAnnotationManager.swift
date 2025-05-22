

import Foundation
import CoreData

/// 악보 필기 관리하는 manager
final class ScoreAnnotationManager {
    static let shared = ScoreAnnotationManager()
    private let context = CoreDataManager.shared.context
    
    /// 저장하기
    func save(annotations: [ScoreAnnotationModel], for pageModel: ScorePageModel){
        print("▶️ [ScoreAnnotationManager.save] called for pageID:", pageModel.s_pid, "with annotation count:", annotations.count)

        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        guard let pageEntity = (try? context.fetch(req))?.first else {
            print("⚠️ Page entity not found for s_pid: \(pageModel.s_pid)")
            return
        }
        
        // 기존 필기 삭제
        if let existing = pageEntity.scoreAnnotations as?  Set<ScoreAnnotation> {
            print("🗑️ [ScoreAnnotationManager.save] deleting existing annotations count:", existing.count)

            existing.forEach(context.delete)
        }
        // 새 필기 삽입
        for anno in annotations {
            let ent = ScoreAnnotation(context: context)
            ent.s_aid = anno.s_aid
            ent.strokeData = anno.strokeData
            ent.scorePage = pageEntity
        }
        print("➕ [ScoreAnnotationManager.save] inserted new annotations count:", annotations.count)

        // 저장하기
        do {
            try context.save()
            print("✅ save success")
        } catch {
            print("❌ [ScoreAnnotationManager.save] save error:", error.localizedDescription)
        }
    }

    /// 불러오기
    func fetch(for pageModel: ScorePageModel) -> [ScoreAnnotationModel]{
        print("▶️ [ScoreAnnotationManager.fetch] called for pageID:", pageModel.s_pid)

        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        
        guard let pageEntity = (try? context.fetch(req))?.first,
              let set = pageEntity.scoreAnnotations as? Set<ScoreAnnotation>
        else {
            print("⚠️ 필기 데이터 없음")
            return []
        }
        print("✅ CoreData 조회 완료: \(set.count)개의 필기 데이터")
        return set.map{ ScoreAnnotationModel(entity: $0)}
    }
    
}
