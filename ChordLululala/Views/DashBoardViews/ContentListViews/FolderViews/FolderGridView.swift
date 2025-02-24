//
//  FolderGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderGridView: View {
    let folders: [ContentModel]
    let cellSpacing: CGFloat = 18
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(folders, id: \.cid) { folder in
                    FolderGridCellView(folder: folder)
                }
            }
        }
    }
}
