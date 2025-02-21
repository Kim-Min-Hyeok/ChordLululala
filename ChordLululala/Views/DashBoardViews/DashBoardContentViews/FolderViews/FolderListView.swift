//
//  FolderListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListView: View {
    let folders: [Content] // 폴더: type == 2
    let cellSpacing: CGFloat = 18
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(folders, id: \.cid) { folder in
                FolderListCellView(folder: folder)
            }
        }
        .padding()
    }
}
