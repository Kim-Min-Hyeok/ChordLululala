//
//  ScoreDetail.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
struct ScoreDetailModel {
    let s_did: UUID
    var key: String      // 원래 키
    var t_key: String    // 변환될 키
    var scorePages: [UUID]  // ScorePage 엔티티와의 관계 (각 ScorePage의 식별자 배열)
}

extension ScoreDetailModel {
    init(entity: ScoreDetail) {
        self.s_did = entity.s_did ?? UUID()
        self.key = entity.key ?? ""
        self.t_key = entity.t_key ?? ""
        if let scorePagesSet = entity.scorePages as? Set<ScorePage> {
            self.scorePages = scorePagesSet.compactMap { $0.s_pid }
        } else {
            self.scorePages = []
        }
    }
}

extension ScoreDetail {
    func update(from model: ScoreDetailModel) {
        self.s_did = model.s_did
        self.key = model.key
        self.t_key = model.t_key
    }
}
