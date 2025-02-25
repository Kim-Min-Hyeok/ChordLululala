//
//  ScoreMemo.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

struct ScoreMemoModel {
    let s_mid: UUID
    var memo: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

extension ScoreMemoModel {
    init(entity: ScoreMemo) {
        self.s_mid = entity.s_mid ?? UUID()
        self.memo = entity.memo ?? ""
        self.x = entity.x
        self.y = entity.y
        self.width = entity.width
        self.height = entity.height
    }
}

extension ScoreMemo {
    func update(from model: ScoreMemoModel) {
        self.s_mid = model.s_mid
        self.memo = model.memo
        self.x = model.x
        self.y = model.y
        self.width = model.width
        self.height = model.height
    }
}
