//
//  FolderGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderGridCellView: View {
    let folder: FolderModel
    var body: some View {
        HStack(spacing: 4.78) {
            Image(systemName: "folder.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.black)
            Text(folder.name)
                .font(.caption)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.leading, 9)
        .frame(maxWidth: .infinity, minHeight: 42, maxHeight: 42)
        .background(Color.gray)
        .cornerRadius(9)
    }
}
