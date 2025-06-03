//
//  ScoreChordManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import Foundation
import CoreData

/// Core Data 저장·조회 관리
final class ScoreChordManager {
    static let shared = ScoreChordManager()
    private let context = CoreDataManager.shared.context
    
    func save(chords: [ScoreChordModel], for pageModel: ScorePageModel) {
        // 1) s_pid 로 ScorePage 엔티티 조회
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        guard let pageEntity = (try? context.fetch(req))?.first else {
            print("⚠️ Page entity not found for s_pid: \(pageModel.s_pid)")
            return
        }
        
        // 2) 기존 코드 삭제
        if let existing = pageEntity.scoreChords as? Set<ScoreChord> {
            existing.forEach(context.delete)
        }
        
        // 3) 새 코드 저장
        for m in chords {
            let ent = ScoreChord(context: context)
            ent.s_cid     = m.s_cid
            ent.chord     = m.chord
            ent.x         = m.x
            ent.y         = m.y
            ent.width     = m.width
            ent.height    = m.height
            ent.scorePage = pageEntity
        }
        
        try? context.save()
    }
    
    /// 도메인 모델을 받아, 저장된 Core Data 코드를 모델로 변환해 반환합니다.
    func fetch(for pageModel: ScorePageModel) -> [ScoreChordModel] {
        let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
        req.predicate = NSPredicate(format: "s_pid == %@", pageModel.s_pid as CVarArg)
        guard let pageEntity = (try? context.fetch(req))?.first,
              let set = pageEntity.scoreChords as? Set<ScoreChord>
        else {
            return []
        }
        return set.map(ScoreChordModel.init(entity:))
    }
    
    func clone(from chords: [ScoreChordModel], to page: ScorePageModel) {
            let req: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
            req.predicate = NSPredicate(format: "s_pid == %@", page.s_pid as CVarArg)

            guard let pageEntity = try? context.fetch(req).first else { return }

            for chord in chords {
                let ent = ScoreChord(context: context)
                ent.s_cid = UUID()
                ent.chord = chord.chord
                ent.x = chord.x
                ent.y = chord.y
                ent.width = chord.width
                ent.height = chord.height
                ent.scorePage = pageEntity
            }

            try? context.save()
        }
}
