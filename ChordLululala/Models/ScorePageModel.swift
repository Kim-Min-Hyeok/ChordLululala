//
//  ScorePage.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
struct ScorePageModel {
    let s_pid: UUID
    var rotation: Int          // 예: 0 ~ 4 값
    var scoreAnnotations: [UUID]
    var scoreMemos: [UUID]
    var scoreChords: [UUID]
}

extension ScorePageModel {
    init(entity: ScorePage) {
        self.s_pid = entity.s_pid ?? UUID()
        self.rotation = Int(entity.rotation)
        
        if let annotationsSet = entity.scoreAnnotations as? Set<ScoreAnnotation> {
            self.scoreAnnotations = annotationsSet.compactMap { $0.s_aid }
        } else {
            self.scoreAnnotations = []
        }
        
        if let memosSet = entity.scoreMemos as? Set<ScoreMemo> {
            self.scoreMemos = memosSet.compactMap { $0.s_mid }
        } else {
            self.scoreMemos = []
        }
        
        if let chordsSet = entity.scoreChords as? Set<ScoreChord> {
            self.scoreChords = chordsSet.compactMap { $0.s_cid }
        } else {
            self.scoreChords = []
        }
    }
}

extension ScorePage {
    func update(from model: ScorePageModel) {
        self.s_pid = model.s_pid
        self.rotation = Int16(model.rotation)
        // scoreAnnotations, scoreMemos, scoreChords와 같은 관계 업데이트는
        // ScoreAnnotation, ScoreMemo, ScoreChord 모델 생성 후 별도 로직으로 관리해야 합니다.
    }
}
