//
//  ScoreAnnotation.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
import Foundation

final class ScoreAnnotationModel: Hashable, Identifiable {
    let s_aid: UUID
    var strokeData: Data

    init(
        s_aid: UUID = UUID(),
        strokeData: Data
    ) {
        self.s_aid = s_aid
        self.strokeData = strokeData
    }

    // MARK: - Entity → Model
    convenience init(entity: ScoreAnnotation) {
        self.init(
            s_aid: entity.s_aid ?? UUID(),
            strokeData: entity.strokeData ?? Data()
        )
    }

    // MARK: - Equatable & Hashable
    static func == (lhs: ScoreAnnotationModel, rhs: ScoreAnnotationModel) -> Bool {
        return lhs.s_aid == rhs.s_aid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(s_aid)
    }
}

extension ScoreAnnotation {
    func update(from model: ScoreAnnotationModel) {
        self.s_aid = model.s_aid
        self.strokeData = model.strokeData
    }
}
