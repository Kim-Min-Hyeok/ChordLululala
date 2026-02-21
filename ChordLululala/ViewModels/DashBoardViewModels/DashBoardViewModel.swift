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
    case date = "날짜"
    case name = "이름"
    
    var id: String { rawValue }
}

enum SortDirection {
    case ascending
    case descending
}

final class DashBoardViewModel: ObservableObject {
    // MARK: 가로/세로 모드 인식
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    // MARK: - 현재 폴더 위치
    @Published var currentParent: Content? = nil
    
    // MARK: - 현재 폴더 내 Contents
    @Published var contents: [Content] = []
    
    // MARK: - 검색 관련
    @Published var isSearching = false
    @Published var searchText = "" {
        didSet { updateSearch(query: searchText) }
    }
    private var savedParent: Content?
    private var savedDashboard: DashboardContents?
    
    func enterSearch() {
        guard !isSearching else { return }
        savedParent    = currentParent
        savedDashboard = dashboardContents
        withAnimation(.easeInOut) {
            self.isSearching = true
        }
        //        contents = []
        updateSearch(query: "")
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
        let allContents = ContentCoreDataManager.shared.fetchContentsSync()
        
        if query.isEmpty {
            contents = allContents.filter { content in
                content.parentContent != nil &&
                content.type != ContentType.scoresOfSetlist.rawValue
            }
        } else {
            contents = allContents.filter { content in
                guard content.parentContent != nil else { return false }
                guard content.type != ContentType.scoresOfSetlist.rawValue else { return false }
                guard let name = content.name else { return false }
                return name.localizedCaseInsensitiveContains(query)
            }
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
                   let setlistBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Setlist") {
                    currentParent = setlistBase
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
    
    // MARK: - 정렬 관련
    //    @Published var isSortModalVisible: Bool = false
    //    @Published var isListGridModalVisible: Bool = false
    
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
    
    // MARK: - 업로드 진행률 관련
    @Published var isUploadingFiles: Bool = false
    @Published var uploadTotalCount: Int = 0
    @Published var uploadCompletedCount: Int = 0
    private var isUploadCancelled: Bool = false
    private var uploadQueue: [URL] = []
    private var isProcessingUploadQueue: Bool = false
    private var isPickerDoneQueuing: Bool = false

    // MARK: - 편집&삭제 모달 관련
    @Published var isRenameModalVisible: Bool = false
    @Published var selectedContent: Content? = nil
    
    // MARK: - 선택모드 관련
    @Published var isSelectionViewVisible: Bool = false
    @Published var isTrashModalVisible: Bool = false
    @Published var isMoveModalVisible: Bool = false
    @Published var selectedContents: [Content] = []
    @Published var moveDestinations: [Content] = []
    @Published var selectedDestination: Content? = nil
    
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
            if let setlist = ContentManager.shared.fetchBaseDirectory(named: "Setlist") {
                currentParent = setlist
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
        
        importFromDropboxAndLoadContents()
    }
    
    func goToSetlistPreservingFolder() {
        preserveCurrentParent = true
        dashboardContents = .setlist
    }
    
    func loadMoveDestinations() {
        var destinations: [Content] = []
        
        switch dashboardContents {
        case .score:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                destinations = [base] +
                ContentCoreDataManager.shared.fetchChildrenSync(for: base)
            }
            
        case .setlist:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Setlist") {
                destinations = [base] +
                ContentCoreDataManager.shared.fetchChildrenSync(for: base)
            }
            
        case .trashCan:
            if let base = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                destinations = [base] +
                ContentCoreDataManager.shared.fetchChildrenSync(for: base)
            }
            
        case .createSetlist, .myPage:
            destinations = []
        }
        
        // 폴더 타입(type == 2)만 남기기
        moveDestinations = destinations.filter { $0.type == ContentType.folder.rawValue }
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
    
    var sortedContents: [Content] {
        let filtered = contents.filter { content in
            guard content.type != ContentType.scoresOfSetlist.rawValue else { return false }
            switch currentFilter {
            case .all:   return true
            case .star:  return content.isStared
            }
        }
        
        // 기본값으로 아주 과거 날짜를 사용
        let defaultDate = Date.distantPast
        
        let sorted: [Content]
        switch selectedSort {
        case .date:
            sorted = filtered.sorted {
                ($0.modifiedAt ?? defaultDate) > ($1.modifiedAt ?? defaultDate)
            }
        case .name:
            sorted = filtered.sorted {
                ($0.name ?? "") < ($1.name ?? "")
            }
        }
        
        return sortDirection == .ascending ? sorted : Array(sorted.reversed())
    }
    
    // MARK: - 폴더 간 이동
    func didTapFolder(_ folder: Content) {
        if isSearching {
            exitSearch()
        }
        
        self.dashboardContents = folder.parentContent?.name == "Score" ? .score :
        folder.parentContent?.name == "Setlist" ? .setlist :
        folder.parentContent?.name == "Trash_Can" ? .trashCan :
            .trashCan
        
        print("📁 Tapping folder: \(folder.name ?? "?"), Dashboard: \(dashboardContents)")
        print("📁 Current parent before: \(currentParent?.name ?? "nil")")
        currentParent = folder
        print("📁 Current parent after: \(currentParent?.name ?? "nil")")
        loadContents()
        
        importFromDropboxAndLoadContents()
    }
    
    func goBack() {
        if isSearching {
            exitSearch()
        }
        guard let current = currentParent else {
            print("현재 베이스 디렉토리입니다. 뒤로 갈 수 없습니다.")
            return
        }
        if let parent = current.parentContent {
            currentParent = parent
        } else {
            switch dashboardContents {
            case .score:
                currentParent = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score")
            case .setlist:
                currentParent = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Setlist")
            case .trashCan:
                currentParent = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can")
            case .createSetlist, .myPage:
                currentParent = nil
            }
        }
        loadContents()
        importFromDropboxAndLoadContents()
    }
    
    // MARK: - Content 관련 비즈니스 로직 호출
    func loadContents() {
        guard let parent = currentParent else { return }
        print("🔍 Loading contents - Parent: \(parent.name ?? "?"), Dashboard: \(dashboardContents)")
        print("🔍 Parent ID: \(parent.objectID)")
        
        ContentManager.shared
            .loadContents(forParent: parent, dashboardContents: dashboardContents)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ Error loading contents: \(error)")
                    }
                },
                receiveValue: { [weak self] fetched in
                    print("✅ Loaded contents: \(fetched.count)")
                    fetched.forEach { content in
                        print("   - \(content.name ?? "?") (parent: \(content.parentContent?.name ?? "nil"))")
                    }
                    self?.contents = fetched
                }
            )
            .store(in: &cancellables)
    }
    
    func uploadFile(with url: URL) {
        guard let parent = currentParent else { return }

        ContentManager.shared
            .createScore(with: url, currentParent: parent, dashboardContents: dashboardContents)
            .compactMap { $0 }
            .flatMap { newContent in
                ScoreDetailManager.shared.createScoreDetail(for: newContent)
            }
            .flatMap { detail in
                guard let pdfURL = ScoreDetailManager.shared.getContentURL(for: detail) else {
                    return Just(()).eraseToAnyPublisher()
                }
                return ScorePageManager.shared.createPages(for: detail, fileURL: pdfURL)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
            }
            .store(in: &cancellables)
    }

    func prepareUpload(totalCount: Int) {
        isUploadCancelled = false
        uploadTotalCount = totalCount
        uploadCompletedCount = 0
        isUploadingFiles = true
        uploadQueue.removeAll()
        isProcessingUploadQueue = false
        isPickerDoneQueuing = false
    }

    func enqueueUploadFile(_ url: URL) {
        uploadQueue.append(url)
        if !isProcessingUploadQueue {
            processNextInQueue()
        }
    }

    func markPickerComplete() {
        isPickerDoneQueuing = true
        checkUploadCompletion()
    }

    func cancelUpload() {
        isUploadCancelled = true
        isUploadingFiles = false
        uploadQueue.removeAll()
        isProcessingUploadQueue = false
    }

    private func processNextInQueue() {
        guard !isUploadCancelled else {
            isUploadingFiles = false
            loadContents()
            return
        }

        guard !uploadQueue.isEmpty else {
            isProcessingUploadQueue = false
            checkUploadCompletion()
            return
        }

        isProcessingUploadQueue = true
        let url = uploadQueue.removeFirst()

        let ext = url.pathExtension.lowercased()
        if ext == "png" || ext == "jpg" || ext == "jpeg" {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let pdfURL = self?.convertImageToPDF(imageURL: url)
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let pdfURL = pdfURL {
                        self.performUpload(url: pdfURL)
                    } else {
                        self.uploadCompletedCount += 1
                        self.isProcessingUploadQueue = false
                        self.processNextInQueue()
                    }
                }
            }
            return
        }

        performUpload(url: url)
    }

    private func performUpload(url: URL) {
        guard let parent = currentParent else {
            isProcessingUploadQueue = false
            isUploadingFiles = false
            return
        }

        ContentManager.shared
            .createScore(with: url, currentParent: parent, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newContent in
                guard let self = self, let newContent = newContent else {
                    self?.uploadCompletedCount += 1
                    self?.isProcessingUploadQueue = false
                    self?.processNextInQueue()
                    return
                }

                ScoreDetailManager.shared.createScoreDetail(for: newContent)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] detail in
                        guard let self = self else { return }

                        guard let pdfURL = ScoreDetailManager.shared.getContentURL(for: detail) else {
                            self.uploadCompletedCount += 1
                            self.isProcessingUploadQueue = false
                            self.processNextInQueue()
                            return
                        }

                        ScorePageManager.shared.createPages(for: detail, fileURL: pdfURL)
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] in
                                self?.uploadCompletedCount += 1
                                self?.isProcessingUploadQueue = false
                                self?.processNextInQueue()
                            }
                            .store(in: &self.cancellables)
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

    private func checkUploadCompletion() {
        if isPickerDoneQueuing && uploadQueue.isEmpty && !isProcessingUploadQueue {
            isUploadingFiles = false
            loadContents()
        }
    }

    private func convertImageToPDF(imageURL: URL) -> URL? {
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        do {
            try pdfData.write(to: pdfURL)
            return pdfURL
        } catch {
            print("PDF 변환 실패: \(error)")
            return nil
        }
    }
    
    func createFolder(folderName: String) {
        guard let parent = currentParent else { return }
        
        ContentManager.shared
            .createFolder(
                named: folderName,
                in: parent,
                dashboardContents: dashboardContents
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func renameContent(_ content: Content, newName: String) {
        print("newName: \(newName)")
        ContentManager.shared
            .renameContent(content, newName: newName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func duplicateContent(_ content: Content) {
        ContentManager.shared
            .duplicateContent(content, dashboardContents: dashboardContents)
            .flatMap { [weak self] cloned in
                print("✅ 클론 생성됨: \(cloned.name ?? "")")
                guard let self = self else { return Just(()).eraseToAnyPublisher() }
                return self.cloneHierarchyIfNeeded(original: content, cloned: cloned)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func duplicateSelectedContents() {
        let tasks = selectedContents.map { original in
            ContentManager.shared.duplicateContent(original, dashboardContents: dashboardContents)
                .flatMap { [weak self] cloned -> AnyPublisher<Void, Never> in
                    guard let self else { return Just(()).eraseToAnyPublisher() }
                    return self.cloneHierarchyIfNeeded(original: original, cloned: cloned)
                }
        }
        
        Publishers.MergeMany(tasks)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedContents.removeAll()
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    private func cloneHierarchyIfNeeded(
        original: Content,
        cloned: Content
    ) -> AnyPublisher<Void, Never> {
        switch ContentType(rawValue: cloned.type) {
        case .score, .scoresOfSetlist:
            return Future<Void, Never> { promise in
                guard let origDetail = ScoreDetailManager.shared.fetchDetail(for: original) else {
                    return promise(.success(()))
                }
                // 1) ScoreDetail 복제
                let newDetail = ScoreDetailManager.shared.cloneDetail(of: origDetail, to: cloned)
                
                // 2) Page 복제
                let origPages = ScorePageManager.shared.fetchPages(for: origDetail)
                let newPages  = ScorePageManager.shared.clonePages(from: origPages, to: newDetail)
                
                // 3) Chord & Annotation 복제
                for (op, np) in zip(origPages, newPages) {
                    let chords = ScoreChordManager.shared.fetchChords(for: op)
                    ScoreChordManager.shared.cloneChords(chords, to: np)
                    
                    let annots = ScoreAnnotationManager.shared.fetchAnnotations(for: op)
                    ScoreAnnotationManager.shared.cloneAnnotations(annots, to: np)
                }
                
                promise(.success(()))
            }
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
            
        case .setlist:
            guard let origScores = original.setlistScores as? Set<Content>,
                  let newScores  = cloned.setlistScores  as? Set<Content> else {
                return Just(()).eraseToAnyPublisher()
            }
            let pairs = zip(Array(origScores), Array(newScores))
            let tasks = pairs.map { orig, newCopy in
                cloneHierarchyIfNeeded(original: orig, cloned: newCopy)
            }
            return Publishers.MergeMany(tasks)
                .collect()
                .map { _ in () }
                .eraseToAnyPublisher()
            
        case .folder:
            guard let children = original.childContent as? Set<Content> else {
                return Just(()).eraseToAnyPublisher()
            }
            let tasks = children.map { child in
                ContentManager.shared
                    .duplicateContent(child, newParent: cloned, dashboardContents: dashboardContents)
                    .flatMap { newChild in
                        self.cloneHierarchyIfNeeded(original: child, cloned: newChild)
                    }
            }
            return Publishers.MergeMany(tasks)
                .collect()
                .map { _ in () }
                .eraseToAnyPublisher()
            
        default:
            return Just(()).eraseToAnyPublisher()
        }
    }
    
    func moveContentToTrash(_ content: Content) {
        ContentManager.shared
            .moveContentToTrash(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func restoreContent(_ content: Content) {
        ContentManager.shared
            .restoreContent(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
    
    func moveSelectedContents(to destination: Content) {
        let moveTasks = selectedContents.map { contentEntity in
            ContentManager.shared
                .moveContent(contentEntity, to: destination)
        }
        Publishers.MergeMany(moveTasks)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedContents.removeAll()
                self?.isMoveModalVisible    = false
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
    
    func deleteContent(_ content: Content) {
        ContentManager.shared.deleteContent(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
            }
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
    
    func toggleContentStared(_ content: Content) {
        ContentManager.shared.toggleContentStared(content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
            }
            .store(in: &cancellables)
    }
    
    func getParentName(of content: Content) -> String {
        guard let parent = content.parentContent else {
            return "전체 폴더"
        }
        if parent.parentContent == nil {
            return "전체 폴더"
        }
        return parent.name ?? "전체 폴더"
    }
    
    /// MARK: 드롭박스에 직접 추가
    func importFromDropboxAndLoadContents() {
        guard dashboardContents == .score else {
            print("드롭박스에서 가져오기: 현재 대시보드가 Score가 아닙니다.")
            return
        }
        guard let parent = currentParent else {
            return
        }
        
        return DropboxImportManager.shared
            .syncCurrentFolderWithFileSystem(parent: parent)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadContents()
                self?.loadMoveDestinations()
            }
            .store(in: &cancellables)
    }
}
