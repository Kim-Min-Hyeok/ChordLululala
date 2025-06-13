//
//  ChordConfirmViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI
import Combine

final class ChordConfirmViewModel: ObservableObject {
    @Published var pagesImages: [UIImage] = []
    @Published var chordLists: [[ScoreChord]] = []
    
    @Published var key: String = "C"
    @Published var t_key: String = "C"
    @Published var isSharp: Bool = true
    
    let sharpKeys: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7
    ]
    
    let flatKeys: [String: Int] = [
        "C": 0, "F": 1, "Bb": 2, "Eb": 3, "Ab": 4, "Db": 5, "Gb": 6, "Cb": 7
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    func load(from content: Content) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: content),
              let pdfURL = ScoreDetailManager.shared.getContentURL(for: detail)
        else { return }

        key = detail.key ?? "C"
        t_key = detail.t_key ?? "C"

        let allPages = ScorePageManager.shared.fetchPages(for: detail)
        let pdfPages = allPages
            .filter { $0.pageType == "pdf" }
            .sorted { ($0.originalPageIndex) < ($1.originalPageIndex) }

        let allImages = PDFProcessor.extractPages(from: pdfURL)

        let minCount = min(3, allImages.count, pdfPages.count)
        let usedPages = Array(pdfPages.prefix(minCount))
        let usedImages = Array(allImages.prefix(minCount))

        self.pagesImages = usedImages
        self.chordLists  = usedPages.map { ScoreChordManager.shared.fetchChords(for: $0) }
    }
    
    func transposedChord(for original: String) -> String {
        guard key != t_key else { return original }

        // 12음계는 고정
        _ = ["C", "C#", "D", "D#", "E", "F",
                           "F#", "G", "G#", "A", "A#", "B"]
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
            // "Abm7" → "Ab"
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }

        guard let from = enharmonicMap[key],
              let to   = enharmonicMap[t_key] else { return original }

        let diff = (to - from + 12) % 12

        if let (idx, matched) = rootIndex(of: original) {
            let displayMap = isSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = original.dropFirst(matched.count)
            return newRoot + suffix
        }

        return original
    }
}
