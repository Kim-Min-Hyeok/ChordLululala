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
        }
    }
    @Published var searchText: String = ""
    
    @Published var files: [FileModel] = MockData.sampleFiles
    @Published var folders: [FolderModel] = MockData.sampleFolders
    
    // 필터: currentFilter에 따라 파일/폴더 목록 분리
    var filteredFolders: [FolderModel] {
        currentFilter == .file ? [] : folders.filter { folder in
            switch selectedContent {
            case .allDocuments:
                return true // 모든 폴더 포함
            case .recentDocuments:
                let calendar = Calendar.current
                let today = Date()
                let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: today)!
                return folder.accessedDate >= oneDayAgo // 최근 접근된 폴더
            case .trashCan:
                return false // trashCan에서 폴더는 제외
            case .songList:
                return false // songList는 폴더를 포함하지 않음
            }
        }
    }
    var filteredFiles: [FileModel] {
        currentFilter == .folder ? [] : files.filter { file in
            switch selectedContent {
            case .allDocuments:
                return true // 모든 파일 포함
            case .recentDocuments:
                let calendar = Calendar.current
                let today = Date()
                let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: today)!
                return file.isTrash == false && file.modifiedDate >= oneDayAgo // 최근 수정된 파일
            case .trashCan:
                return file.isTrash // trashCan: isTrash가 true인 파일만
            case .songList:
                return false // songList는 파일을 포함하지 않음
            }
        }
    }
    
    // 정렬: selectedSort에 따라 정렬 (여기선 단순 name 정렬 예시)
    var sortedFolders: [FolderModel] {
        switch selectedSort {
        case .date: return filteredFolders
        case .name: return filteredFolders.sorted { $0.name < $1.name }
        }
    }
    var sortedFiles: [FileModel] {
        switch selectedSort {
        case .date: return filteredFiles
        case .name: return filteredFiles.sorted { $0.name < $1.name }
        }
    }
}
