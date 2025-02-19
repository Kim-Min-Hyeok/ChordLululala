//
//  FileListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListView: View {
    let files: [FileModel]
    let cellSpacing: CGFloat
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(files) { file in
                FileListCellView(file: file)
            }
        }
        .padding()
    }
}
