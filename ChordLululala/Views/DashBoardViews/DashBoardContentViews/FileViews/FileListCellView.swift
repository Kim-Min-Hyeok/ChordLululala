//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListCellView: View {
    let file: FileModel
    var body: some View {
        VStack() {
            HStack(spacing: 12) {
                file.image
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.black)
                Text(file.name)
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            Divider()
        }
        .background(Color.clear)
        .frame(height: 53)
    }
}
