//
//  ChordAddingModalViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

final class ChordAddingModalViewModel: ObservableObject {
    @Published var chord: String = ""
    
    private var undoStack: [String] = []
    private var redoStack: [String] = []
    
    func setInitialChord(_ value: String) {
        chord = value
        undoStack = [""]
        redoStack = []
    }
    
    func append(_ value: String) {
        undoStack.append(chord)
        redoStack.removeAll()
        chord += value
    }
    
    func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(chord)
        chord = last
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(chord)
        chord = next
    }
    
    func isValidChord(_ text: String) -> Bool {
        if text.isEmpty { return true }
        let p = #"^[A-G](?:[#b])?(M|m|maj|min|dim|aug)?(6|7|9|11|13)?(sus2|sus4|add9|add2|b5|#9|b9|#11|b13)?(?:/[A-G](?:[#b])?)?$"#
        return text.range(of: p, options: .regularExpression) != nil
    }
}
