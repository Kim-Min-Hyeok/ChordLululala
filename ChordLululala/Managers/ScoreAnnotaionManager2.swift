//
//  ScoreAnnotaionManager2.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/25/25.
//

import Foundation
import CoreData

final class ScoreAnnotationManager2 {
    static let shared = ScoreAnnotationManager2()
    private let context = CoreDataManager.shared.context

    /// 특정 ScorePageModel에 연결된 모든 Annotation을 저장
    func save(annotations: [ScoreAnnotationModel], for pageModel: ScorePageModel) {
        // 1) s_pid 기준으로 ScorePage 찾기
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        guard let pageEntity = (try? context.fetch(req))?.first else {
            print("⚠️ Page entity not found for s_pid: \(pageModel.s_pid)")
            return
        }

        // 2) 기존 Annotation 삭제
        if let existing = pageEntity.scoreAnnotations as? Set<ScoreAnnotation> {
            existing.forEach(context.delete)
        }

        // 3) 새로운 Annotation 저장
        for model in annotations {
            let annotationEntity = ScoreAnnotation(context: context)
            annotationEntity.s_aid = model.s_aid
            annotationEntity.strokeData = model.strokeData
            annotationEntity.scorePage = pageEntity
        }

        try? context.save()
    }

    /// 특정 ScorePageModel에서 연결된 Annotation 모델을 조회
    func fetch(for pageModel: ScorePageModel) -> [ScoreAnnotationModel] {
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        guard let pageEntity = (try? context.fetch(req))?.first,
              let set = pageEntity.scoreAnnotations as? Set<ScoreAnnotation>
        else {
            return []
        }
        return set.map(ScoreAnnotationModel.init(entity:))
    }
}
