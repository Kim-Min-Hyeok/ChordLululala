//
//  FolderGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderGridView: View {
    let folders: [Content]
    let cellSpacing: CGFloat = 18
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    var onFolderTap: (Content) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(folders, id: \.cid) { folder in
                    // 폴더 셀을 버튼 형태로 생성
                    FolderGridCellView(folder: folder, onTap: {
                        onFolderTap(folder)
                    })
                }
            }
        }
    }
}

