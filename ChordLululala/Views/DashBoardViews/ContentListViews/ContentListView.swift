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
        if viewModel.sortedContents.isEmpty {
            VStack {
                Image("empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 81)
                Text("비어있음")
                    .textStyle(.headingMdSemiBold)
                    .foregroundColor(Color.primaryGray600)
                    .padding(.top, 15)
                Text("새로운 파일을 업로드하거나 폴더를 생성하세요")
                    .textStyle(.bodyTextXLMedium)
                    .foregroundColor(Color.primaryGray300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 154)
        }
        else {
            ScrollView {
                if isListView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.sortedContents, id: \.cid) { content in
                            if content.type == .folder {
                                FolderListCellView(folder: content)
                            } else {
                                FileListCellView(file: content)
                            }
                        }
                    }
                } else {
                    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(viewModel.sortedContents, id: \.cid) { content in
                            if content.type == .folder {
                                FolderGridCellView(folder: content)
                            } else {
                                FileGridCellView(file: content)
                            }
                        }
                    }
                }
            }
        }
    }
}
