//
//  CreateSetlistViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import Combine
import SwiftUI

final class CreateSetlistViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var currentFilter: ToggleFilter = .all
    @Published var selectedContents: [ContentModel] = []
    
    private var allScores: [ContentModel] = []
    
    var filteredScores: [ContentModel] {
        // 1. 검색어 필터
        let queryFiltered: [ContentModel] = {
            guard !searchText.isEmpty else { return allScores }
            return allScores.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }()
        
        // 2. 즐겨찾기 필터
        switch currentFilter {
        case .all:
            return queryFiltered
        case .star:
            return queryFiltered.filter { $0.isStared }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        let all = ContentCoreDataManager.shared.fetchContentModelsSync()
        self.allScores = all.filter { $0.type == .score }
    }
    
    func toggleSelection(content: ContentModel) {
        if isSelected(content: content) {
            unselectContent(content: content)
        } else {
            selectContent(content: content)
        }
    }
    
    func isSelected(content: ContentModel) -> Bool {
        selectedContents.contains { $0.cid == content.cid }
    }
    
    func selectContent(content: ContentModel) {
        selectedContents.append(content)
    }
    
    func unselectContent(content: ContentModel) {
        selectedContents.removeAll { $0 == content }
    }
    
    func moveSelectedContent(from source: IndexSet, to destination: Int) {
        selectedContents.move(fromOffsets: source, toOffset: destination)
    }
    
    /// providers 로 넘어온 아이템을 `selectedContents`의 원하는 위치(index)에 삽입하도록 수정
    func selectByDragAndDrop(providers: [NSItemProvider], at index: Int) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadObject(ofClass: NSString.self) { nsStr, _ in
            guard
                let str = nsStr as? String,
                let uuid = UUID(uuidString: str),
                let dropped = self.filteredScores.first(where: { $0.cid == uuid })
            else { return }

            DispatchQueue.main.async {
                // 중복 방지
                guard !self.selectedContents.contains(where: { $0.cid == dropped.cid }) else { return }
                // 삽입 위치 보정 (예: index가 배열 크기보다 크면 맨 끝)
                let safeIndex = min(index, self.selectedContents.count)
                self.selectedContents.insert(dropped, at: safeIndex)
                print("✅ 드롭 완료—선택된 파일들:", self.selectedContents.map(\.name))
            }
        }
        return true
    }
    
    func createSetlist(_ name: String, currentParent: ContentModel, completion: @escaping () -> Void) {
        let scoresToClone = selectedContents

        ContentManager.shared
            .createSetlist(
                named: name,
                with: scoresToClone,
                currentParent: currentParent,
                dashboardContents: .setlist
            )
            .flatMap { setlist -> AnyPublisher<Void, Never> in
                let tasks = zip(scoresToClone, setlist.scores ?? []).map { originalScore, newScore in
                    return ScoreDetailManager.shared.createScoreDetail(for: newScore)
                        .handleEvents(receiveOutput: { newDetail in
                            // 1. 페이지 복제
                            guard let originalDetail = ScoreDetailManager.shared.fetchScoreDetailModel(for: originalScore) else { return }

                            let originalPages = ScorePageManager.shared.fetchPageModels(for: originalDetail)
                            ScorePageManager.shared.clonePages(from: originalPages, to: newDetail)

                            // 2. 페이지별 Chord & Annotation 복제
                            let newPages = ScorePageManager.shared.fetchPageModels(for: newDetail)
                            for (origPage, newPage) in zip(originalPages, newPages) {
                                let origChords = ScoreChordManager.shared.fetch(for: origPage)
                                let origAnnotations = ScoreAnnotationManager2.shared.fetch(for: origPage)

                                ScoreChordManager.shared.save(chords: origChords, for: newPage)
                                ScoreAnnotationManager2.shared.save(annotations: origAnnotations, for: newPage)
                            }
                        })
                        .map { _ in () }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(tasks)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in
                print("✅ 셋리스트 생성 완료")
                self?.selectedContents.removeAll()
                completion()
            }
            .store(in: &cancellables)
    }
}
