//
//  FolderListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListView: View {
    let folders: [FolderModel]
    let cellSpacing: CGFloat
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(folders) { folder in
                FolderListCellView(folder: folder)
            }
        }
        .padding()
    }
}
