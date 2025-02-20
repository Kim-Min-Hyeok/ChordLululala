//
//  FileGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileGridView: View {
    let files: [FileModel]
    let cellSpacing: CGFloat
    let columns: [GridItem]
    
    init(files: [FileModel], cellSpacing: CGFloat) {
        self.files = files
        self.cellSpacing = cellSpacing
        self.columns = Array(repeating: GridItem(.flexible(), spacing: cellSpacing), count: 4)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(files) { file in
                    FileGridCellView(file: file)
                }
            }
        }
    }
}
