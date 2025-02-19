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
    // 사이드바 열림 상태 (기존 DocumentViewModel에서 관리하던 값)
    @Published var isSidebarVisible: Bool = false
    
    // 파일/폴더 필터 상태
    @Published var currentFilter: ToggleFilter = .all
    // 정렬 옵션 상태
    @Published var selectedSort: SortOption = .date
    // 내부 콘텐츠 전환 상태
    @Published var selectedContent: DashboardContent = .allDocuments {
        didSet {
            // 콘텐츠가 바뀌면 기본값으로 초기화
            currentFilter = .all
            selectedSort = .date
            searchText = ""
        }
    }
    // 검색어 상태
    @Published var searchText: String = ""
}
