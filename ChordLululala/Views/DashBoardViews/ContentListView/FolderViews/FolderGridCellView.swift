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
    var onEllipsisTapped: (CGRect) -> Void
    
    @State private var cellFrame: CGRect = .zero
    
    var body: some View {
        HStack() {
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
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            Button(action: {
                onEllipsisTapped(cellFrame)
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            .frame(width: 44, height: 44)
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        self.cellFrame = geo.frame(in: .global)
                    }
            }
        )
    }
}
