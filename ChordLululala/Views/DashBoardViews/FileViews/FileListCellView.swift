//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListCellView: View {
    let file: Content
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
            .frame(height: 53)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 54)
        .overlay(
            Divider()
                .frame(height: 1)
                .background(Color.gray),
            alignment: .bottom
        )
    }
}
