//
//  ScoreDetail.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

final class ScoreDetailModel: Hashable, Identifiable {
    let s_did: UUID
    var key: String         // 원래 키
    var t_key: String       // 변환될 키
    var scorePages: [ScorePageModel]

    // MARK: - 생성자
    init(
        s_did: UUID = UUID(),
        key: String,
        t_key: String,
        scorePages: [ScorePageModel] = []
    ) {
        self.s_did = s_did
        self.key = key
        self.t_key = t_key
        self.scorePages = scorePages
    }

    // MARK: - Entity → Model 변환
    convenience init(entity: ScoreDetail) {
        let pageModels = (entity.scorePages as? Set<ScorePage>)?.map { ScorePageModel(entity: $0) } ?? []
        self.init(
            s_did: entity.s_did ?? UUID(),
            key: entity.key ?? "",
            t_key: entity.t_key ?? "",
            scorePages: pageModels
        )
    }

    // MARK: - Hashable & Equatable
    static func == (lhs: ScoreDetailModel, rhs: ScoreDetailModel) -> Bool {
        return lhs.s_did == rhs.s_did
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(s_did)
    }
}

extension ScoreDetail {
    func update(from model: ScoreDetailModel) {
        self.s_did = model.s_did
        self.key = model.key
        self.t_key = model.t_key
    }
}
