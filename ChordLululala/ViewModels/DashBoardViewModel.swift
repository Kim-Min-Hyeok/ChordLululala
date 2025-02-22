//
//  DocumentViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Combine
import SwiftUI

enum DashboardContent {
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
    @Published var selectedContent: DashboardContent = .allDocuments {
        didSet {
            // 콘텐츠 변경 시 필터, 정렬, 검색어 기본값으로 초기화
            currentFilter = .all
            selectedSort = .date
            searchText = ""
            loadContents()
        }
    }
    @Published var searchText: String = ""
    @Published var currentParent: Content? = nil
    @Published var contents: [Content] = []
    
    // MARK: 편집 모달 관련 상태
    @Published var contentForEdit: Content? = nil
    @Published var modalFrame: CGRect = .zero
    @Published var showModifyModal: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // 초기 load
    init() {
        loadContents()
    }
    
    func loadContents() {
        var predicate: NSPredicate
        
        // 현재 폴더가 있다면, 해당 폴더의 cid와 일치하는 parent를 가진 항목만 불러옴
        if let parentID = currentParent?.cid {
            predicate = NSPredicate(format: "parent == %@", parentID as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        
        // 선택된 DashboardContent에 따른 추가 필터링
        switch selectedContent {
        case .trashCan:
            let trashPredicate = NSPredicate(format: "isTrash == YES")
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate])
        case .recentDocuments:
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let recentPredicate = NSPredicate(format: "modifiedAt >= %@", oneDayAgo as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, recentPredicate])
        default:
            break
        }
        
        ContentManager.shared.fetchContents(predicate: predicate)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Fetch contents error: \(error)")
                }
            } receiveValue: { [weak self] contents in
                self?.contents = contents
            }
            .store(in: &cancellables)
    }
    
    
    // 폴더 셀 탭 시 호출. 해당 폴더로 들어가기 위해 currentParent를 업데이트
    func didTapFolder(_ folder: Content) {
        currentParent = folder
        loadContents()
    }
    
    func goBack() {
        if let parentID = currentParent?.parent {
            ContentManager.shared.fetchContent(with: parentID) { [weak self] parentFolder in
                DispatchQueue.main.async {
                    self?.currentParent = parentFolder
                    self?.loadContents()
                }
            }
        } else {
            // 상위 폴더가 없으면 루트로 돌아감.
            currentParent = nil
            loadContents()
        }
    }
    
    // MARK: 정렬 관련 코드들
    // 폴더 정렬: lastAccessedAt이 nil인 경우 Date.distantPast로 비교
    var sortedFolders: [Content] {
        let folders = contents.filter { $0.type == 2 }
        switch selectedSort {
        case .date:
            return folders.sorted {
                ($0.lastAccessedAt ?? Date.distantPast) < ($1.lastAccessedAt ?? Date.distantPast)
            }
        case .name:
            return folders.sorted {
                ($0.name ?? "") < ($1.name ?? "")
            }
        }
    }
    
    // 파일 정렬: 동일한 방식 사용
    var sortedFiles: [Content] {
        let files = contents.filter { $0.type != 2 }
        switch selectedSort {
        case .date:
            return files.sorted {
                ($0.lastAccessedAt ?? Date.distantPast) < ($1.lastAccessedAt ?? Date.distantPast)
            }
        case .name:
            return files.sorted {
                ($0.name ?? "") < ($1.name ?? "")
            }
        }
    }
    
    // MARK: Create 관련 코드들
    // 파일 업로드
    func uploadFile(with selectedURL: URL) {
        if let destinationURL = FileManagerManager.shared.copyPDFToScoreFolder(from: selectedURL) {
            // 절대 경로를 Documents 기준의 상대 경로로 변환
            if let relativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
                ContentManager.shared.createContent(
                    name: destinationURL.lastPathComponent,
                    path: relativePath, // 상대 경로 저장
                    type: 0,       // score
                    category: 0,   // score
                    parent: currentParent?.cid,   // 현재 폴더가 없으면 root
                    s_dids: nil
                )
                loadContents()
            } else {
                print("상대 경로 계산 실패")
            }
        }
    }
    
    // 폴더 생성 (FileManager로 실제 폴더 생성하지 않고 Core Data에 폴더 Content 생성)
    func createFolder(folderName: String) {
        // 폴더는 실제 파일 시스템의 경로가 필요 없으므로 빈 문자열("") 혹은 적절한 값으로 지정
        ContentManager.shared.createContent(
            name: folderName,
            path: nil,      // 실제 디렉토리 생성 없이 Core Data 상 폴더 정보만 관리
            type: 2,       // folder
            category: 0,   // score (또는 원하는 카테고리)
            parent: currentParent?.cid,  // 루트이면 nil, 아니면 현재 폴더의 cid
            s_dids: nil
        )
        loadContents()
    }
    
    // MARK: Update 관련 코드들
    // 파일/폴더 이름 수정
    func renameContent(_ content: Content, newName: String) {
        let isFile = content.type != 2
        let updatedName = isFile ? newName + ".pdf" : newName
        content.name = updatedName
        content.modifiedAt = Date()
        
        if isFile, let oldPath = content.path,
           let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let oldURL = docsURL.appendingPathComponent(oldPath)
            let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(updatedName)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    content.path = newRelativePath
                }
            } catch {
                print("파일 이름 변경 실패: \(error)")
            }
        }
        // Core Data 에 저장
        saveContext()
    }
    
    // MARK: 복제 관련 코드들
    // 복제: 파일인 경우, 같은 parent 하위에 "(n)" 형식으로 복제; 폴더는 재귀 복제
    func duplicateContent(_ content: Content) {
        if content.type != 2 {
            // 파일 복제
            let newName = generateDuplicateFileName(for: content)
            if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
               let oldPath = content.path {
                let oldURL = docsURL.appendingPathComponent(oldPath)
                let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newName)
                do {
                    try FileManager.default.copyItem(at: oldURL, to: newURL)
                    if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                        ContentManager.shared.createContent(
                            name: newName,
                            path: newRelativePath,
                            type: 0,
                            category: content.category,
                            parent: content.parent,
                            s_dids: nil
                        )
                    }
                } catch {
                    print("파일 복제 실패: \(error)")
                }
            }
        } else {
            // 폴더 복제 – 폴더와 그 하위 콘텐츠를 재귀적으로 복제
            let newFolderName = generateDuplicateFolderName(for: content)
            // 새로운 폴더 Content 생성
            ContentManager.shared.createContent(
                name: newFolderName,
                path: nil,
                type: 2,
                category: content.category,
                parent: content.parent,
                s_dids: nil
            )
            // 재귀적 복제: 현재 폴더의 자식 콘텐츠를 가져와서 복제 (간단 예시)
            if let cid = content.cid {
                let childPredicate = NSPredicate(format: "parent == %@", cid as CVarArg)
                ContentManager.shared.fetchContents(predicate: childPredicate)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case let .failure(error) = completion {
                            print("폴더 자식 복제 fetch error: \(error)")
                        }
                    } receiveValue: { [weak self] children in
                        guard !children.isEmpty else { return }
                        children.forEach { child in
                            self?.duplicateContent(child)
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        saveContext()
        loadContents()
    }
    
    private func generateDuplicateFileName(for content: Content) -> String {
        guard content.type != 2, let originalName = content.name else { return "Unnamed.pdf" }
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        var index = 1
        var newName = "\(baseName) (\(index)).\(ext)"
        if let scoreFolder = FileManagerManager.shared.scoreFolderURL {
            while FileManager.default.fileExists(atPath: scoreFolder.appendingPathComponent(newName).path) {
                index += 1
                newName = "\(baseName) (\(index)).\(ext)"
            }
        }
        return newName
    }
    
    private func generateDuplicateFolderName(for content: Content) -> String {
        let baseName = content.name ?? "Unnamed"
        var index = 1
        var newName = "\(baseName) (\(index))"
        let siblingFolders = sortedFolders.filter { $0.parent == content.parent }
        while siblingFolders.contains(where: { $0.name == newName }) {
            index += 1
            newName = "\(baseName) (\(index))"
        }
        return newName
    }
    
    // MARK: 휴지통 이동
    func moveContentToTrash(_ content: Content) {
        content.isTrash = true
        content.modifiedAt = Date()
        // 파일인 경우: 파일 시스템 상에서 Trash_Can 폴더로 이동
        if content.type != 2, let oldPath = content.path,
           let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let trashURL = FileManagerManager.shared.trashCanFolderURL {
            let oldURL = docsURL.appendingPathComponent(oldPath)
            let newURL = trashURL.appendingPathComponent(oldURL.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                // 새 위치(상대 경로)로 업데이트
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    content.path = newRelativePath
                }
            } catch {
                print("파일 휴지통 이동 실패: \(error)")
            }
        }
        // Core Data 저장
        saveContext()
        loadContents()
    }
    
    // MARK: 저장 처리
    private func saveContext() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Core Data 저장 실패: \(error)")
        }
    }
}
