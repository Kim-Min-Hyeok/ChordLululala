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
    
    @Published var contents: [Content] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // 초기 load
    init() {
        loadContents()
    }
    
    func loadContents() {
        var predicate: NSPredicate? = nil
        
        switch selectedContent {
        case .trashCan:
            predicate = NSPredicate(format: "isTrash == YES")
        case .recentDocuments:
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            predicate = NSPredicate(format: "modifiedAt >= %@", oneDayAgo as NSDate)
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
            ContentManager.shared.createContent(
                name: destinationURL.lastPathComponent,
                path: destinationURL.path,
                type: 0,       // score
                category: 0,   // score
                parent: nil,   // 현재 폴더가 없으면 root
                s_dids: nil
            )
            loadContents()
        }
    }
}
