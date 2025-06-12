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
    
    func save(chords: [ScoreChord], for page: ScorePage) {
        // 1) 기존 관계에 묶여 있던 코드 전부 삭제
        let existing = (page.scoreChords as? Set<ScoreChord>) ?? []
        existing.forEach(context.delete)

        // 2) 스테이징된 ScoreChord 엔티티들에 다시 page 연결
        chords.forEach { chord in
            chord.scorePage = page
        }

        // 3) 한 번만 save()
        do {
            try context.save()
            print("✅ save(chords:for:) 완료 – 총 \(chords.count)개 코드 저장")
        } catch {
            print("❌ save(chords:for:) 실패:", error)
        }
    }
    
    /// 도메인 모델을 받아, 저장된 Core Data 코드를 모델로 변환해 반환합니다.
    func fetchChords(for page: ScorePage) -> [ScoreChord] {
        return Array(page.scoreChords as? Set<ScoreChord> ?? [])
    }
    
    /// originalChords를 newPage로 복제
    func cloneChords(_ originalChords: [ScoreChord], to newPage: ScorePage) {
        for chord in originalChords {
            let nc = ScoreChord(context: context)
            nc.chord     = chord.chord
            nc.x         = chord.x
            nc.y         = chord.y
            nc.width     = chord.width
            nc.height    = chord.height
            nc.scorePage = newPage
        }
        try? context.save()
    }
}
