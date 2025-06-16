//
//  ScoreSetlistOverViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/17/25.
//

import Combine
import SwiftUI

final class ScoreSetlistOverViewModel: ObservableObject{
    @Published var searchText: String = ""
    @Published var currentFilter: ToggleFilter = .all
    @Published var selectedContents: [Content] = []
    
    private var allScores: [Content] = []
    
    var filteredScores: [Content] {
        // 1. 검색어 필터
        let queryFiltered: [Content] = {
            guard !searchText.isEmpty else { return allScores }
            return allScores.filter { content in
                guard let name = content.name else { return false }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }()
        
        return queryFiltered
        // 2. 즐겨찾기 필터
//        switch currentFilter {
//        case .all:  return queryFiltered
//        case .star: return queryFiltered.filter { $0.isStared }
//        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        let all = ContentCoreDataManager.shared.fetchContentsSync()
        self.allScores = all.filter { $0.type == ContentType.score.rawValue && $0.deletedAt == nil}
    }
    
    func toggleSelection(content: Content) {
        if isSelected(content: content) {
            unselectContent(content: content)
        } else {
            selectContent(content: content)
        }
    }
    
    func isSelected(content: Content) -> Bool {
        selectedContents.contains { $0.objectID == content.objectID }
    }
    
    func selectContent(content: Content) {
        selectedContents.append(content)
    }
    
    func unselectContent(content: Content) {
        selectedContents.removeAll { $0 == content }
    }
}
