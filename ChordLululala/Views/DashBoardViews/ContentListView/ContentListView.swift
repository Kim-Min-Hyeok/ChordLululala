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
    
    // 클로저
    var onFolderTap: ((Content) -> Void)? = nil
    var onFolderEllipsisTapped: ((Content, CGRect) -> Void)? = nil
    var onFileTap: ((Content) -> Void)? = nil
    var onFileEllipsisTapped: ((Content, CGRect) -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: (isListView ? 8 : 80)) {
                // 폴더 영역: 현재 필터가 전체 또는 폴더이면 표시
                if viewModel.currentFilter == .all || viewModel.currentFilter == .folder {
                    if isListView {
                        FolderListView(
                            folders: viewModel.sortedFolders,
                            onFolderTap: { folder in
                                onFolderTap?(folder)
                            },
                            onEllipsisTapped: { folder, frame in
                                onFolderEllipsisTapped?(folder, frame)
                            }
                        )
                    } else {
                        FolderGridView(
                            folders: viewModel.sortedFolders,
                            onFolderTap: { folder in
                                onFolderTap?(folder)
                            },
                            onEllipsisTapped: { folder, frame in
                                onFolderEllipsisTapped?(folder, frame)
                            }
                        )
                    }
                }
                // 파일 영역: 현재 필터가 전체 또는 파일이면 표시
                if viewModel.currentFilter == .all || viewModel.currentFilter == .file {
                    if isListView {
                        FileListView(
                            files: viewModel.sortedFiles,
                            onFileTap: { file in
                                onFileTap?(file)
                            },
                            onEllipsisTapped: { file, frame in
                                onFileEllipsisTapped?(file, frame)
                            }
                        )
                    } else {
                        FileGridView(
                            files: viewModel.sortedFiles,
                            onEllipsisTapped: { file, frame in
                                onFileEllipsisTapped?(file, frame)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 168)
        }
    }
}
