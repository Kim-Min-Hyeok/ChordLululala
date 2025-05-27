//
//  ScoreChord.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

final class ScoreChordModel: Hashable, Identifiable {
    let s_cid: UUID
    var chord: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    init(
        s_cid: UUID = UUID(),
        chord: String,
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) {
        self.s_cid = s_cid
        self.chord = chord
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    // MARK: - Entity → Model
    convenience init(entity: ScoreChord) {
        self.init(
            s_cid: entity.s_cid ?? UUID(),
            chord: entity.chord ?? "",
            x: entity.x,
            y: entity.y,
            width: entity.width,
            height: entity.height
        )
    }

    // MARK: - Equatable & Hashable
    static func == (lhs: ScoreChordModel, rhs: ScoreChordModel) -> Bool {
        return lhs.s_cid == rhs.s_cid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(s_cid)
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
