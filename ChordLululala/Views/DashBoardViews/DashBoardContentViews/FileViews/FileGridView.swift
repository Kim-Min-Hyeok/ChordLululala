//
//  FileGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileGridView: View {
    let files: [Content]  // 파일: type != 2
    let cellSpacing: CGFloat = 8
    // 4열 그리드로 구성
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(files, id: \.cid) { file in
                    FileGridCellView(file: file)
                }
            }
            .padding()
        }
    }
}

