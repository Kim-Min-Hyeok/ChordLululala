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
    
    @Published var pageKeys:  [String] = []
    @Published var pageTKeys: [String] = []
    @Published var isSharp: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    func transposedChord(
        for original: String,
        atPage pageIndex: Int
    ) -> String {
        let key    = pageKeys.indices.contains(pageIndex)
        ? pageKeys[pageIndex] : pageKeys.first ?? "C"
        let t_key  = pageTKeys.indices.contains(pageIndex)
        ? pageTKeys[pageIndex] : pageTKeys.first ?? "C"
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
        
        func transposeSingle(_ note: String, from: String, to: String) -> String {
            guard let fromIdx = enharmonicMap[from],
                  let toIdx = enharmonicMap[to],
                  let (idx, matched) = rootIndex(of: note) else { return note }
            let diff = (toIdx - fromIdx + 12) % 12
            let isSharp = ["C", "G", "D", "A", "E", "B", "F#", "C#"].contains(to)
            let displayMap = isSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = note.dropFirst(matched.count)
            return newRoot + suffix
        }
        
        func rootIndex(of chord: String) -> (index: Int, matched: String)? {
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }
        
        let parts = original.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        let chordPart = String(parts[0])
        let bassPart = parts.count > 1 ? String(parts[1]) : nil
        
        let transposedChord = transposeSingle(chordPart, from: key, to: t_key)
        let transposedBass = bassPart != nil ? transposeSingle(bassPart!, from: key, to: t_key) : nil
        
        
        if let bass = transposedBass {
            return "\(transposedChord)/\(bass)"
        } else {
            return transposedChord
        }
    }
}
