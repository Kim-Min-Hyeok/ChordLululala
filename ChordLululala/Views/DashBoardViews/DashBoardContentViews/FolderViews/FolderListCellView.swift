//
//  FolderListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListCellView: View {
    let folder: Content
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.blue)
                Text(folder.name ?? "Unnamed")
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            Divider()
        }
        .frame(height: 53)
    }
}
