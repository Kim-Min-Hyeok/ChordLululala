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
