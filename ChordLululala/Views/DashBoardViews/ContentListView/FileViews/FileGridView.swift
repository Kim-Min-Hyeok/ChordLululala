//
//  FileGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileGridView: View {
    let files: [Content]
    let cellSpacing: CGFloat = 18
    // onEllipsisTapped: Content와 global frame를 함께 전달
    var onEllipsisTapped: (Content, CGRect) -> Void = { _, _ in }
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(files, id: \.cid) { file in
                    FileGridCellView(file: file) { frame in
                        onEllipsisTapped(file, frame)
                    }
                }
            }
        }
    }
}

