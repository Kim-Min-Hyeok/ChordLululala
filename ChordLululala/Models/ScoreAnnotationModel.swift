//
//  ScoreAnnotation.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
struct ScoreAnnotationModel {
    let s_aid: UUID
    var strokeData: Data    // 벡터 또는 바이너리 데이터 (byte[])
}

extension ScoreAnnotationModel {
    init(entity: ScoreAnnotation) {
        self.s_aid = entity.s_aid ?? UUID()
        self.strokeData = entity.strokeData ?? Data()
    }
}

extension ScoreAnnotation {
    func update(from model: ScoreAnnotationModel) {
        self.s_aid = model.s_aid
        self.strokeData = model.strokeData
    }
}
