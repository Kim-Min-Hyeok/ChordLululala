//
//  ScoreSetlistOverViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/13/25.
//

import Foundation
import SwiftUI

final class ScoreSetlistOverViewModel: ObservableObject {
    @Published var scores: [Content] = []
    
    private var setlist: Content?
    
    func setSetlist(_ setlist: Content) {
        self.setlist = setlist
        self.scores = ContentManager.shared.fetchScoresFromSetlist(setlist)
    }
    
    func moveScore(from source: IndexSet, to destination: Int) {
        guard setlist != nil else { return }
        var updatedScores = scores
        updatedScores.move(fromOffsets: source, toOffset: destination)
        
        ContentManager.shared.updateSetlistDisplayOrder(for: updatedScores)
        self.scores = updatedScores
    }
    
    func deleteScore(_ score: Content) {
        guard setlist != nil else { return }
        guard let removedIndex = scores.firstIndex(where: { $0.objectID == score.objectID }) else { return }

        let orderedScores = scores

        if ContentManager.shared.removeScoreFromSetlist(score, in: orderedScores) {
            self.scores.remove(at: removedIndex)
        }
    }
}
