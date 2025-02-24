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
    
    // MARK: - 현재 폴더 위치 (도메인 모델 사용)
    @Published var currentParent: ContentModel? = nil
    
    // MARK: - 현재 폴더 내 Contents (파일/폴더, 도메인 모델)
    @Published var contents: [ContentModel] = []
    
    // MARK: - 필터링 관련
    @Published var currentFilter: ToggleFilter = .all
    @Published var selectedSort: SortOption = .date
    @Published var dashboardContents: DashboardContents = .allDocuments {
        didSet {
            currentFilter = .all
            selectedSort = .date
            searchText = ""
            
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
    }
    @Published var searchText: String = ""
    
    // MARK: - 사이드바 관련
    @Published var isSidebarVisible: Bool = false
    @Published var sidebarDragOffset: CGFloat = 0
    
    // MARK: - 리스트/그리드 관련
    @Published var isListView: Bool = true
    
    // MARK: - 파일/폴더 생성 버튼 관련
    @Published var isFloatingMenuVisible: Bool = false
    @Published var isPDFPickerVisible: Bool = false
    @Published var isCreateFolderModalVisible: Bool = false
    
    // MARK: - 편집&삭제 모달 관련
    @Published var isModifyModalVisible: Bool = false
    @Published var isDeletedModalVisible: Bool = false
    @Published var selectedContent: ContentModel? = nil
    @Published var cellFrame: CGRect = .zero
    
    // MARK: - 선택모드 관련
    @Published var isSelectionViewVisible: Bool = false
    @Published var isTrashModalVisible: Bool = false
    @Published var selectedContents: [ContentModel] = []
    
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
    
    // MARK: - 폴더 및 파일 정렬
    var sortedFolders: [ContentModel] {
        let folders = contents.filter { $0.type == .folder }
        switch selectedSort {
        case .date:
            return folders.sorted { $0.lastAccessedAt < $1.lastAccessedAt }
        case .name:
            return folders.sorted { $0.name < $1.name }
        }
    }
    
    var sortedFiles: [ContentModel] {
        let files = contents.filter { $0.type != .folder }
        switch selectedSort {
        case .date:
            return files.sorted { $0.lastAccessedAt < $1.lastAccessedAt }
        case .name:
            return files.sorted { $0.name < $1.name }
        }
    }
    
    // MARK: - 폴더 간 이동
    func didTapFolder(_ folder: ContentModel) {
        currentParent = folder
        loadContents()
    }
    
    func goBack() {
        guard let current = currentParent, let parent = current.parent else {
            print("현재 베이스 디렉토리입니다. 뒤로 갈 수 없습니다.")
            return
        }
        if let parentFolder = ContentManager.shared.fetchContentModel(with: parent) {
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
    
    // MARK: - Content 관련 비즈니스 로직 호출

    func loadContents() {
            guard let parent = currentParent else { return }
        ContentManager2.shared.loadContentModels(forParent: parent, dashboardContents: dashboardContents)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error loading contents: \(error)")
                    }
                }, receiveValue: { [weak self] models in
                    self?.contents = models
                })
                .store(in: &cancellables)
        }
        
        func uploadFile(with url: URL) {
            guard let currentParent = currentParent else { return }
            ContentManager2.shared.uploadFile(with: url, currentParent: currentParent, dashboardContents: dashboardContents)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
        
        func createFolder(folderName: String) {
            guard let currentParent = currentParent else { return }
            ContentManager2.shared.createFolder(folderName: folderName, currentParent: currentParent, dashboardContents: dashboardContents)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
        
        func renameContent(_ content: ContentModel, newName: String) {
            ContentManager2.shared.renameContent(content, newName: newName)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
        
        func duplicateContent(_ content: ContentModel) {
            ContentManager2.shared.duplicateContent(content, dashboardContents: dashboardContents)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
        
        func duplicateSelectedContents() {
            let publishers = selectedContents.map { content in
                ContentManager2.shared.duplicateContent(content, dashboardContents: dashboardContents)
            }
            Publishers.MergeMany(publishers)
                .collect()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.selectedContents.removeAll()
                    self?.loadContents()
                }
                .store(in: &cancellables)
        }
        
        func moveContentToTrash(_ content: ContentModel) {
            ContentManager2.shared.moveContentToTrash(content)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
        
        func moveSelectedContentsToTrash() {
            let publishers = selectedContents.map { content in
                ContentManager2.shared.moveContentToTrash(content)
            }
            Publishers.MergeMany(publishers)
                .collect()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.selectedContents.removeAll()
                    self?.loadContents()
                }
                .store(in: &cancellables)
        }
        
        func deleteContent(_ content: ContentModel) {
            ContentManager2.shared.deleteContent(content)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.loadContents() }
                .store(in: &cancellables)
        }
}

//    func loadContents() {
//        guard let parent = currentParent else { return }
//        ContentInteractor.shared.loadContentModels(forParent: parent, dashboardContents: dashboardContents)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                if case let .failure(error) = completion {
//                    print("Error loading contents: \(error)")
//                }
//            }, receiveValue: { [weak self] models in
//                self?.contents = models
//            })
//            .store(in: &cancellables)
//    }
//
//    func uploadFile(with url: URL) {
//        guard let currentParent = currentParent else { return }
//        ContentInteractor.shared.uploadFile(with: url, currentParent: currentParent, dashboardContents: dashboardContents)
//        loadContents()
//    }
//
//    func createFolder(folderName: String) {
//        guard let currentParent = currentParent else { return }
//        ContentInteractor.shared.createFolder(folderName: folderName, currentParent: currentParent, dashboardContents: dashboardContents)
//        loadContents()
//    }
//
//    func renameContent(_ content: ContentModel, newName: String) {
//        ContentInteractor.shared.renameContent(content, newName: newName)
//        loadContents()
//    }
//
//    func duplicateContent(_ content: ContentModel) {
//        ContentInteractor.shared.duplicateContent(content, dashboardContents: dashboardContents)
//        loadContents()
//    }
//
//    func duplicateSelectedContents() {
//        for content in selectedContents {
//            ContentInteractor.shared.duplicateContent(content, dashboardContents: dashboardContents)
//        }
//        selectedContents.removeAll()
//        loadContents()
//    }
//
//    func moveContentToTrash(_ content: ContentModel) {
//        ContentInteractor.shared.moveContentToTrash(content)
//        loadContents()
//    }
//
//    func moveSelectedContentsToTrash() {
//        for content in selectedContents {
//            ContentInteractor.shared.moveContentToTrash(content)
//        }
//        selectedContents.removeAll()
//        loadContents()
//    }
//
//    func deleteContent(_ content: ContentModel) {
//        ContentInteractor.shared.deleteContent(content)
//        loadContents()
//    }
