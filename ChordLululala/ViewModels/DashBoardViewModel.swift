//
//  DashBoardViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Combine
import SwiftUI

enum DashboardContents {
    case allDocuments
    case recentDocuments
    case songList
    case trashCan
}

enum ToggleFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case file = "파일"
    case folder = "폴더"
    
    var id: String { rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case date = "날짜순"
    case name = "이름순"
    
    var id: String { rawValue }
}

final class DashBoardViewModel: ObservableObject {
    @Published var isSidebarVisible: Bool = false
    @Published var currentFilter: ToggleFilter = .all
    @Published var selectedSort: SortOption = .date
    @Published var dashboardContents: DashboardContents = .allDocuments {
        didSet {
            currentFilter = .all
            selectedSort = .date
            searchText = ""
            loadContents()
        }
    }
    @Published var searchText: String = ""
    @Published var currentParent: Content? = nil
    @Published var contents: [Content] = []
    
    // 편집 모달 관련 상태
    @Published var cellFrame: CGRect = .zero
    @Published var showModifyModal: Bool = false
    @Published var selectedContent: Content? = nil
    
    // 선택 모드 상태 (추가)
    @Published var isSelectionMode: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 앱 시작 시 기본 디렉토리 Content 객체들을 초기화합니다.
        ContentManager.shared.initializeBaseDirectories()
        // 선택된 DashboardContent에 따라 기본 디렉토리를 currentParent로 지정합니다.
        switch dashboardContents {
        case .allDocuments, .recentDocuments:
            if let scoreBase = ContentManager.shared.fetchBaseDirectory(named: "Score") {
                currentParent = scoreBase
            }
        case .songList:
            if let songListBase = ContentManager.shared.fetchBaseDirectory(named: "Song_List") {
                currentParent = songListBase
            }
        case .trashCan:
            if let trashCanBase = ContentManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                currentParent = trashCanBase
            }
        }
        loadContents()
    }
    
    // Content 업데이트
    func loadContents() {
        ContentInteractor.shared.loadContents(forParent: currentParent, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error loading contents: \(error)")
                }
            }, receiveValue: { [weak self] contents in
                self?.contents = contents
            })
            .store(in: &cancellables)
    }
    
    // MARK: 폴더 및 파일 정렬
    // 1. 폴더
    var sortedFolders: [Content] {
        let folders = contents.filter { $0.type == 2 }
        switch selectedSort {
        case .date:
            return folders.sorted { ($0.lastAccessedAt ?? Date.distantPast) < ($1.lastAccessedAt ?? Date.distantPast) }
        case .name:
            return folders.sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
    }

    // 2. 파일
    var sortedFiles: [Content] {
        let files = contents.filter { $0.type != 2 }
        switch selectedSort {
        case .date:
            return files.sorted { ($0.lastAccessedAt ?? Date.distantPast) < ($1.lastAccessedAt ?? Date.distantPast) }
        case .name:
            return files.sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
    }
    
    // MARK: 폴더 간 이동
    // 1. 하위 폴더 이동
    func didTapFolder(_ folder: Content) {
        currentParent = folder
        loadContents()
    }
    
    // 2. 상위 폴더 이동: 기본 디렉토리(Score, Song_List, Trash_Can)에서는 goBack 동작 X
    func goBack() {
            guard let current = currentParent, let parentID = current.parent else {
                print("현재 베이스 디렉토리입니다. 뒤로 갈 수 없습니다.")
                return
            }
            // 동기적으로 부모 폴더를 가져옵니다.
            if let parentFolder = ContentManager.shared.fetchContent(with: parentID) {
                currentParent = parentFolder
            } else {
                print("부모 폴더를 찾지 못했습니다. 뒤로 갈 수 없습니다.")
                switch dashboardContents {
                case .allDocuments, .recentDocuments:
                    if let scoreBase = ContentManager.shared.fetchBaseDirectory(named: "Score") {
                        currentParent = scoreBase
                    }
                case .songList:
                    if let songListBase = ContentManager.shared.fetchBaseDirectory(named: "Song_List") {
                        currentParent = songListBase
                    }
                case .trashCan:
                    if let trashCanBase = ContentManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                        currentParent = trashCanBase
                    }
                }
            }
            loadContents()
        }

    
    // MARK: Content 관련 비즈니스 로직 호출
    func uploadFile(with url: URL) {
        ContentInteractor.shared.uploadFile(with: url, currentParent: currentParent, dashboardContents: dashboardContents)
        loadContents()
    }
    
    func createFolder(folderName: String) {
        ContentInteractor.shared.createFolder(folderName: folderName, currentParent: currentParent, dashboardContents: dashboardContents)
        loadContents()
    }
    
    func renameContent(_ content: Content, newName: String) {
        ContentInteractor.shared.renameContent(content, newName: newName)
        loadContents()
    }
    
    func duplicateContent(_ content: Content) {
        ContentInteractor.shared.duplicateContent(content, dashboardContents: dashboardContents)
        loadContents()
    }
    
    func moveContentToTrash(_ content: Content) {
        ContentInteractor.shared.moveContentToTrash(content)
        loadContents()
    }
}
