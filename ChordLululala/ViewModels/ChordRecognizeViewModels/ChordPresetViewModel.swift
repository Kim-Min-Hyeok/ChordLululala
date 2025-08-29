import SwiftUI

final class ChordPresetViewModel: ObservableObject {
    @Published var recentChords: [String] = []
    @Published var isVisible: Bool = false
    
    private let maxCount: Int = 6
    
    func initializeWithFrequencies(from scoreChords: [[ScoreChord]], transposer: (String) -> String) {
        var counter: [String: Int] = [:]
        for page in scoreChords {
            for chord in page {
                let text = transposer(chord.chord ?? "")
                guard text.isEmpty == false else { continue }
                counter[text, default: 0] += 1
            }
        }
        let sorted = counter.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        let uniqueTop = sorted.map { $0.key }.prefix(maxCount)
        recentChords = Array(uniqueTop)
    }
    
    func push(_ chord: String) {
        guard chord.isEmpty == false else { return }
        var list = recentChords.filter { $0 != chord }
        list.insert(chord, at: 0)
        if list.count > maxCount { list = Array(list.prefix(maxCount)) }
        recentChords = list
    }
} 