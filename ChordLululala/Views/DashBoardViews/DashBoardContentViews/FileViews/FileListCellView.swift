//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListCellView: View {
    let file: Content
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext")
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.black)
                Text(file.name ?? "Unnamed")
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            Divider()
        }
        .frame(height: 53)
    }
}
