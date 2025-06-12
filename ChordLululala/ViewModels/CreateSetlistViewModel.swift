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
        
        // 2. 즐겨찾기 필터
        switch currentFilter {
        case .all:  return queryFiltered
        case .star: return queryFiltered.filter { $0.isStared }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        let all = ContentCoreDataManager.shared.fetchContentsSync()
        self.allScores = all.filter { $0.type == ContentType.score.rawValue }
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
    
    func moveSelectedContent(from source: IndexSet, to destination: Int) {
        selectedContents.move(fromOffsets: source, toOffset: destination)
    }
    
    /// providers 로 넘어온 아이템을 `selectedContents`의 원하는 위치(index)에 삽입하도록 수정
    func selectByDragAndDrop(providers: [NSItemProvider], at index: Int) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadObject(ofClass: NSString.self) { nsStr, _ in
            guard
                let str = nsStr as? String,
                // objectID URI 문자열과 비교
                let dropped = self.filteredScores.first(
                    where: {
                        $0.objectID.uriRepresentation().absoluteString == str
                    }
                )
            else { return }

            DispatchQueue.main.async {
                // 중복 방지: objectID 로 비교
                guard !self.selectedContents.contains(
                    where: { $0.objectID == dropped.objectID }
                ) else { return }

                // 삽입 위치 보정
                let safeIndex = min(index, self.selectedContents.count)
                self.selectedContents.insert(dropped, at: safeIndex)
                print("✅ 드롭 완료—선택된 파일들:",
                      self.selectedContents.map { $0.name ?? "Unnamed" })
            }
        }
        return true
    }
    
    func createSetlist(
        _ name: String,
        currentParent: Content,
        completion: @escaping () -> Void
    ) {
        let originals: [Content] = selectedContents

        let setlistPublisher: AnyPublisher<Content, Never> =
            ContentManager.shared
                .createSetlist(
                    named: name,
                    with: originals,
                    currentParent: currentParent
                )
                .eraseToAnyPublisher()

        setlistPublisher
            .flatMap(maxPublishers: .max(1)) { (setlist: Content) -> AnyPublisher<Void, Never> in
                // 1) newScores 타입 명시
                let newScores: [Content] = (setlist.setlistScores as? Set<Content>)?.map { $0 } ?? []

                // 2) zip 결과를 Array로 변환해서 타입 고정
                let pairs: [(Content, Content)] = Array(zip(originals, newScores))

                // 3) tasks 배열 명시
                let tasks: [AnyPublisher<Void, Never>] = pairs.map { orig, copy in
                    Future<Void, Never> { promise in
                        guard let origDetail = ScoreDetailManager.shared.fetchDetail(for: orig) else {
                            promise(.success(()))
                            return
                        }
                        
                        // 2) cloneDetail은 non-optional을 반환하므로 일반 할당
                        let newDetail = ScoreDetailManager.shared.cloneDetail(of: origDetail, to: copy)
                        
                        
                        // 페이지 복제
                        let origPages = ScorePageManager.shared.fetchPages(for: origDetail)
                        let newPages  = ScorePageManager.shared.clonePages(from: origPages, to: newDetail)

                        // 코드·어노테이션 복제
                        for (origPage, newPage) in zip(origPages, newPages) {
                                let chords     = ScoreChordManager.shared.fetchChords(for: origPage)
                                ScoreChordManager.shared.cloneChords(chords, to: newPage)

                                let annots     = ScoreAnnotationManager.shared.fetchAnnotations(for: origPage)
                                ScoreAnnotationManager.shared.cloneAnnotations(annots, to: newPage)
                            }

                        promise(.success(()))
                    }
                    .eraseToAnyPublisher()
                }

                // 4) MergeMany 결과도 변수에 담기
                let merged: AnyPublisher<Void, Never> =
                    Publishers.MergeMany(tasks)
                        .collect()
                        .map { _ in () }
                        .eraseToAnyPublisher()

                return merged
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                print("✅ 셋리스트 생성 완료")
                self?.selectedContents.removeAll()
                completion()
            })
            .store(in: &cancellables)
    }
}
