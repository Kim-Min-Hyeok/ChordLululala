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
    var onFolderTap: (Content) -> Void
    // 전달 시, 해당 폴더와 ellipsis 버튼의 global frame을 함께 넘김
    var onEllipsisTapped: (Content, CGRect) -> Void = { _, _ in }
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(folders, id: \.cid) { folder in
                    FolderGridCellView(folder: folder, onTap: {
                        onFolderTap(folder)
                    }, onEllipsisTapped: { frame in
                        onEllipsisTapped(folder, frame)
                    })
                }
            }
        }
    }
}
