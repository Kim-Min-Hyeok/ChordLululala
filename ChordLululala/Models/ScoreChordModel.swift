//
//  ScoreChord.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

struct ScoreChordModel {
    let s_cid: UUID
    var chord: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

extension ScoreChordModel {
    init(entity: ScoreChord) {
        self.s_cid = entity.s_cid ?? UUID()
        self.chord = entity.chord ?? ""
        self.x = entity.x
        self.y = entity.y
        self.width = entity.width
        self.height = entity.height
    }
}

extension ScoreChord {
    func update(from model: ScoreChordModel) {
        self.s_cid = model.s_cid
        self.chord = model.chord
        self.x = model.x
        self.y = model.y
        self.width = model.width
        self.height = model.height
    }
}
