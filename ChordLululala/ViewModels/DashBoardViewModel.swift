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
                    parent: nil,   // 현재 폴더가 없으면 root
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
}
