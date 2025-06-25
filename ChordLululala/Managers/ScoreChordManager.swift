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
    private var context: NSManagedObjectContext { CoreDataManager.shared.context }
    
    func save(chords: [ScoreChord], for page: ScorePage) {
        // 1) 기존 코드 삭제
        if let existing = page.scoreChords as? Set<ScoreChord> {
            for chord in existing {
                if !chords.contains(where: { $0.objectID == chord.objectID }) {
                    context.delete(chord)
                }
            }
        }

        // 2) 새로운 코드 연결
        for chord in chords {
            if chord.managedObjectContext == nil {
                chord.id = chord.id ?? UUID()
                context.insert(chord)
            }
            chord.scorePage = page
        }

        // 3) 저장
        do {
            try context.save()
            print("✅ save(chords:for:) 완료 – 총 \(chords.count)개 코드 저장")
            for (index, chord) in chords.enumerated() {
                let text = chord.chord ?? "nil"
                print("  [\(index)] chord: \(text), x: \(chord.x), y: \(chord.y), w: \(chord.width), h: \(chord.height)")
            }
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
            nc.id        = UUID()
            nc.chord     = chord.chord
            nc.x         = chord.x
            nc.y         = chord.y
            nc.width     = chord.width
            nc.height    = chord.height
            nc.scorePage = newPage
        }
        try? context.save()
    }
    
    func deleteChords(_ chords: [ScoreChord]) {
        for chord in chords {
            context.delete(chord)
        }
        try? context.save()
    }
}
