//
//  FileListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListView: View {
    let files: [ContentModel]
    let cellSpacing: CGFloat = 8
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(files, id: \.cid) { file in
                FileListCellView(file: file)
            }
        }
    }
}
