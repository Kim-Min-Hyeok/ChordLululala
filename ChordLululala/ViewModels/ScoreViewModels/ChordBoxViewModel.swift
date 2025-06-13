//
//  ChordBoxViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/8/25.
//

import SwiftUI
import Combine

final class ChordBoxViewModel: ObservableObject {
    @Published var chordsForPages: [[ScoreChord]] = []

    @Published var key: String = "C"
    @Published var t_key: String = "C"
    @Published var isSharp: Bool = true

    private var cancellables = Set<AnyCancellable>()

    func transposedChord(for original: String) -> String {
        guard key != t_key else { return original }

        let enharmonicMap: [String: Int] = [
            "C": 0, "B#": 0,
            "C#": 1, "Db": 1,
            "D": 2,
            "D#": 3, "Eb": 3,
            "E": 4, "Fb": 4,
            "F": 5, "E#": 5,
            "F#": 6, "Gb": 6,
            "G": 7,
            "G#": 8, "Ab": 8,
            "A": 9,
            "A#": 10, "Bb": 10,
            "B": 11, "Cb": 11
        ]
        let displayMapSharp = ["C", "C#", "D", "D#", "E", "F",
                               "F#", "G", "G#", "A", "A#", "B"]
        let displayMapFlat  = ["C", "Db", "D", "Eb", "E", "F",
                               "Gb", "G", "Ab", "A", "Bb", "B"]

        func rootIndex(of chord: String) -> (index: Int, matched: String)? {
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }

        guard let from = enharmonicMap[key],
              let to   = enharmonicMap[t_key] else { return original }

        let diff = (to - from + 12) % 12

        if let (idx, matched) = rootIndex(of: original) {
            let isSharp = ["C", "G", "D", "A", "E", "B", "F#", "C#"].contains(t_key)
            let displayMap = isSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = original.dropFirst(matched.count)
            return newRoot + suffix
        }

        return original
    }
}
