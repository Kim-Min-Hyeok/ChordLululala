//
//  FileListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListView: View {
    let files: [Content]
    let cellSpacing: CGFloat = 8
    var onFileTap: (Content) -> Void
    var onEllipsisTapped: (Content, CGRect) -> Void = { _, _ in }
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(files, id: \.cid) { file in
                FileListCellView(
                    file: file,
                    onTap: { onFileTap(file) },
                    onEllipsisTapped: { frame in
                        onEllipsisTapped(file, frame)
                    }
                )
            }
        }
    }
}
