//
//  FolderGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI

struct FolderGridCellView: View {
    let folder: Content
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
                Text(folder.name ?? "Unnamed")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
}
