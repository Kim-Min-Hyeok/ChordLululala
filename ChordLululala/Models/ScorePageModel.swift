//
//  ScorePage.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

final class ScorePageModel: Hashable, Identifiable {
    let s_pid: UUID
    var rotation: Int                  // 회전 값 (예: 0~4)
    var pageType: String?
    var originalPageIndex: Int?        // 원본 pdf 순서
    var displayOrder: Int?             // 실제 화면에 보여지는 순서
    var scoreAnnotations: [ScoreAnnotationModel]
    var scoreChords: [ScoreChordModel]
    
    

    init(
        s_pid: UUID = UUID(),
        rotation: Int,
        pageType: String? = nil,
        originalPageIndex: Int? = nil,
        displayOrder: Int? = nil,
        scoreAnnotations: [ScoreAnnotationModel] = [],
        scoreChords: [ScoreChordModel] = []
    ) {
        self.s_pid = s_pid
        self.rotation = rotation
        self.pageType = pageType
        self.originalPageIndex = originalPageIndex
        self.displayOrder = displayOrder
        self.scoreAnnotations = scoreAnnotations
        self.scoreChords = scoreChords
    }

    // MARK: - Entity → Model 변환
    convenience init(entity: ScorePage) {
        let annotations = (entity.scoreAnnotations as? Set<ScoreAnnotation>)?.map { ScoreAnnotationModel(entity: $0) } ?? []
        let chords = (entity.scoreChords as? Set<ScoreChord>)?.map { ScoreChordModel(entity: $0) } ?? []

        self.init(
            s_pid: entity.s_pid ?? UUID(),
            rotation: Int(entity.rotation),
            pageType: entity.pageType,
            originalPageIndex: Int(entity.originalPageIndex),
            displayOrder: Int(entity.displayOrder),
            scoreAnnotations: annotations,
            scoreChords: chords
        )
    }

    // MARK: - Equatable & Hashable
    static func == (lhs: ScorePageModel, rhs: ScorePageModel) -> Bool {
        return lhs.s_pid == rhs.s_pid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(s_pid)
    }
}

extension ScorePage {
    func update(from model: ScorePageModel) {
        self.s_pid = model.s_pid
        self.rotation = Int16(model.rotation)
        self.pageType = model.pageType
        self.originalPageIndex = Int16(model.originalPageIndex ?? -1)
        self.displayOrder = Int16(model.displayOrder ?? -1)
        // scoreAnnotations, scoreChords와 같은 관계 업데이트는
        // ScoreAnnotation, ScoreChord 모델 생성 후 별도 로직으로 관리해야 합니다.
    }
}
