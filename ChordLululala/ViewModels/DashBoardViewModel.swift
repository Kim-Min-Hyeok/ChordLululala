//
//  DashBoardViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Combine
import SwiftUI

enum DashboardContents {
    case score
    case setlist
    case createSetlist
    case trashCan
    case myPage
}

enum ToggleFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case star = "즐겨찾기"
    
    var id: String { rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case date = "최근 수정순"
    case name = "이름순"
    
    var id: String { rawValue }
}

enum SortDirection {
    case ascending
    case descending
}

final class DashBoardViewModel: ObservableObject {
    // MARK: 가로/세로 모드 인식
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    // MARK: - 현재 폴더 위치 (도메인 모델 사용)
    @Published var currentParent: ContentModel? = nil
    
    // MARK: - 현재 폴더 내 Contents (파일/폴더, 도메인 모델)
    @Published var contents: [ContentModel] = []
    
    // MARK: - 검색 관련
    @Published var isSearching = false
    @Published var searchText = "" {
        didSet { updateSearch(query: searchText) }
    }
    private var savedParent: ContentModel?
    private var savedDashboard: DashboardContents?
    
    func enterSearch() {
        guard !isSearching else { return }
        savedParent    = currentParent
        savedDashboard = dashboardContents
        withAnimation(.easeInOut) {
            self.isSearching = true
        }
        contents = []
    }
    
    func exitSearch() {
        guard isSearching else { return }
        searchText  = ""
        if let dash   = savedDashboard { dashboardContents = dash   }
        if let parent = savedParent      { currentParent    = parent }
        loadContents()
        withAnimation(.easeInOut) {
            isSearching    = false
        }
    }
    
    func updateSearch(query: String) {
        guard isSearching else { return }
        let all = ContentCoreDataManager.shared.fetchContentModelsSync()
        contents = all.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - 필터링 관련
    @Published var currentFilter: ToggleFilter = .all
    @Published var selectedSort: SortOption = .date
    @Published var sortDirection: SortDirection = .ascending
    @Published var dashboardContents: DashboardContents = .score {
        didSet {
            currentFilter = .all
            selectedSort = .date
            // 대시보드 종류에 따라 기본 폴더를 지정
            switch dashboardContents {
            case .score:
                if let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                    currentParent = scoreBase
                }
            case .setlist:
                        if !preserveCurrentParent,
                           let songListBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                            currentParent = songListBase
                        }
            case .trashCan:
                if let trashCanBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                    currentParent = trashCanBase
                }
            case .myPage:
                break
            case .createSetlist:
                break
            }
            preserveCurrentParent = false
            loadContents()
            loadMoveDestinations()
        }
    }
    
    // MARK: - 사이드바 관련
    
    // MARK: - 리스트/그리드 관련
    @Published var isListView: Bool = false
    
    // MARK: - 파일/셋리스트/폴더 생성 버튼 관련
    @Published var isFloatingMenuVisible: Bool = false
    @Published var isAlbumPickerVisible: Bool = false
    @Published var isPDFPickerVisible: Bool = false
    @Published var isCreateSetlistModalVisible: Bool = false
    @Published var isCreateFolderModalVisible: Bool = false
    @Published var nameOfSetlistCreating: String = ""
    private var preserveCurrentParent: Bool = false
    
    // MARK: - 편집&삭제 모달 관련
    @Published var isRenameModalVisible: Bool = false
    @Published var selectedContent: ContentModel? = nil
    
    // MARK: - 선택모드 관련
    @Published var isSelectionViewVisible: Bool = false
    @Published var isTrashModalVisible: Bool = false
    @Published var isMoveModalVisible: Bool = false
    @Published var selectedContents: [ContentModel] = []
    @Published var moveDestinations: [ContentModel] = []
    @Published var selectedDestination: ContentModel? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 앱 시작 시 기본 디렉토리 초기화
        ContentManager.shared.initializeBaseDirectories()
        // 초기 대시보드에 따른 기본 폴더 지정
        switch dashboardContents {
        case .score:
            if let scoreBase = ContentManager.shared.fetchBaseDirectory(named: "Score") {
                currentParent = scoreBase
            }
        case .setlist:
            if let songListBase = ContentManager.shared.fetchBaseDirectory(named: "Song_List") {
                currentParent = songListBase
            }
        case .trashCan:
            if let trashCanBase = ContentManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                currentParent = trashCanBase
            }
        case .myPage:
            break
        case .createSetlist:
            break
        }
        loadContents()
        loadMoveDestinations()
    }
    
    func goToSetlistPreservingFolder() {
        preserveCurrentParent = true
        dashboardContents = .setlist
    }
    
    // 파일 이동 가능 폴더 가져오기
    func loadMoveDestinations() {
        var destinations: [ContentModel] = []
        switch dashboardContents {
        case .score:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                destinations = [base] + ContentCoreDataManager.shared.fetchChildrenModels(for: base.cid)
            }
        case .setlist:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                destinations = [base] + ContentCoreDataManager.shared.fetchChildrenModels(for: base.cid)
            }
        case .trashCan:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                destinations = [base] + ContentCoreDataManager.shared.fetchChildrenModels(for: base.cid)
            }
        case .createSetlist:
            destinations = []
        case .myPage:
            destinations = []
        }
        
        // 폴더 타입만 남기기
        moveDestinations = destinations.filter { $0.type == .folder }
    }
    
    // MARK: - 폴더 및 파일 정렬
    func toggleSortOption(_ option: SortOption) {
        if selectedSort == option {
            // 같은 옵션이면 방향만 바꾸기
            sortDirection = (sortDirection == .ascending) ? .descending : .ascending
        } else {
            // 새 옵션 선택 시 오름차순으로 초기화
            selectedSort = option
            sortDirection = .ascending
        }
    }
    
    var sortedContents: [ContentModel] {
        let filtered = contents.filter { content in
            switch currentFilter {
            case .all: return true
            case .star: return content.isStared
            }
        }

        let sorted: [ContentModel]
        switch selectedSort {
        case .date:
            sorted = filtered.sorted { $0.modifiedAt < $1.modifiedAt }
        case .name:
            sorted = filtered.sorted { $0.name < $1.name }
        }

        return sortDirection == .ascending ? sorted : sorted.reversed()
    }
    
    // MARK: - 폴더 간 이동
    func didTapFolder(_ folder: ContentModel) {
        if isSearching {
            exitSearch()
        }
        currentParent = folder
        loadContents()
    }
    
        func goBack() {
            if isSearching {
                exitSearch()
            }
            guard let current = currentParent else {
                print("현재 베이스 디렉토리입니다. 뒤로 갈 수 없습니다.")
                return
            }
            guard let parent = current.parentContent else {
                print("현재 폴더 \(current.name)에는 부모 폴더가 없습니다. 뒤로 갈 수 없습니다.")
                return
            }
            if let parentFolder = ContentManager.shared.fetchContentModel(with: parent.cid) {
            currentParent = parentFolder
        } else {
            print("부모 폴더를 찾지 못했습니다. 뒤로 갈 수 없습니다.")
            switch dashboardContents {
            case .score:
                if let scoreBase = ContentManager.shared.fetchBaseDirectory(named: "Score") {
                    currentParent = scoreBase
                }
            case .setlist:
                if let songListBase = ContentManager.shared.fetchBaseDirectory(named: "Song_List") {
                    currentParent = songListBase
                }
            case .trashCan:
                if let trashCanBase = ContentManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                    currentParent = trashCanBase
                }
            case .createSetlist:
                break
            case .myPage:
                break
            }
        }
        loadContents()
    }
    
    // MARK: - Content 관련 비즈니스 로직 호출
    
    func loadContents() {
        guard let parent = currentParent else { return }
        
        print("🔍 Loading contents - Parent: \(parent), Dashboard: \(dashboardContents)")
        
        ContentManager.shared.loadContentModels(forParent: parent, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("❌ Error loading contents: \(error)")
                }
            }, receiveValue: { [weak self] models in
                print("✅ Loaded contents: \(models.count)")
                self?.contents = models
            })
            .store(in: &cancellables)
    }
    
    func uploadFile(with url: URL) {
        guard let parent = currentParent else { return }

        ContentManager.shared
            .uploadFile(
                with: url,
                currentParent: parent,
                dashboardContents: dashboardContents
            )
            .compactMap { $0 }  // nil 걸러내기
            .flatMap { cm in
                // 1) ContentModel → ScoreDetail 생성 또는 조회
                ScoreDetailManager.shared.createScoreDetail(for: cm)
            }
            .flatMap { detail in
                // 2) ScoreDetailModel → PDF URL
                guard let pdfURL = ScoreDetailManager.shared.getContentURL(for: detail) else {
                    return Just(()).eraseToAnyPublisher()
                }
                // 3) PDF URL → ScorePage 생성
                return ScorePageManager.shared.createPages(for: detail, fileURL: pdfURL)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
            }
            .store(in: &cancellables)
    }
    
    func createFolder(folderName: String) {
        guard let currentParent = currentParent else { return }
        ContentManager.shared.createFolder(folderName: folderName, currentParent: currentParent, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func renameContent(_ content: ContentModel, newName: String) {
        print("newName: \(newName)")
        ContentManager.shared.renameContent(content, newName: newName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func duplicateContent(_ content: ContentModel) {
        ContentManager.shared.duplicateContent(content, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func duplicateSelectedContents() {
        let publishers = selectedContents.map { content in
            ContentManager.shared.duplicateContent(content, dashboardContents: dashboardContents)
        }
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedContents.removeAll()
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func moveContentToTrash(_ content: ContentModel) {
        ContentManager.shared.moveContentToTrash(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func restoreContent(_ content: ContentModel) {
        ContentManager.shared.restoreContent(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func moveSelectedContents(to destination: ContentModel) {
        let publishers = selectedContents.map { content in
            ContentManager.shared.moveContent(content, to: destination)
        }
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedContents.removeAll()
                self?.isMoveModalVisible = false
                self?.isSelectionViewVisible = false
                self?.loadContents()
            }
            .store(in: &cancellables)
    }
    
    func moveSelectedContentsToTrash() {
        let publishers = selectedContents.map { content in
            ContentManager.shared.moveContentToTrash(content)
        }
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedContents.removeAll()
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func deleteContent(_ content: ContentModel) {
        ContentManager.shared.deleteContent(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.loadContents() }
            .store(in: &cancellables)
    }
    
    func deleteAllContents() {
        let publishers = sortedContents.map { content in
            ContentManager.shared.deleteContent(content)
        }
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadContents()
            }
            .store(in: &cancellables)
    }
    
    func toggleContentStared(_ content: ContentModel) {
        ContentManager.shared.toggleContentStared(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
            }
            .store(in: &cancellables)
    }
    
    func getParentName(of content: ContentModel) -> String {
        guard
            let pid = content.parentContent?.cid,
            let parent = ContentCoreDataManager.shared.fetchContentModel(with: pid)
        else {
            return "전체 폴더"
        }
        return parent.parentContent == nil ? "전체 폴더" : parent.name
    }
}
