//
//  ContentListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/22/25.
//

import SwiftUI

struct ContentListView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    var isListView: Bool
    var isSelectionMode: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: (isListView ? 8 : 80)) {
                // 폴더 영역: 현재 필터가 전체 또는 폴더이면 표시
                if isListView {
                    FolderListView(folders: viewModel.sortedFolders)
                } else {
                    FolderGridView(folders: viewModel.sortedFolders)
                }
                // 파일 영역: 현재 필터가 전체 또는 파일이면 표시
                if isListView {
                    FileListView(files: viewModel.sortedFiles)
                } else {
                    FileGridView(files: viewModel.sortedFiles)
                }
            }
            .padding(.horizontal, 168)
        }
    }
}
