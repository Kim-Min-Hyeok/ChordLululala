//
//  FolderGridView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderGridView: View {
    let folders: [FolderModel]
    let cellSpacing: CGFloat
    let columns: [GridItem]
    
    init(folders: [FolderModel], cellSpacing: CGFloat) {
        self.folders = folders
        self.cellSpacing = cellSpacing
        self.columns = Array(repeating: GridItem(.flexible(), spacing: cellSpacing), count: 4)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(folders) { folder in
                    FolderGridCellView(folder: folder)
                }
            }
        }
    }
}
