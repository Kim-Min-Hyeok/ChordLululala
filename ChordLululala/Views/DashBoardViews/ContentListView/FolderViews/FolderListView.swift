//
//  FolderListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListView: View {
    let folders: [Content]
    let cellSpacing: CGFloat = 8
    var onFolderTap: (Content) -> Void
    var onEllipsisTapped: (Content, CGRect) -> Void = { _, _ in }
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(folders, id: \.cid) { folder in
                FolderListCellView(folder: folder, onTap: {
                    onFolderTap(folder)
                }, onEllipsisTapped: { frame in
                    onEllipsisTapped(folder, frame)
                })
            }
        }
    }
}

