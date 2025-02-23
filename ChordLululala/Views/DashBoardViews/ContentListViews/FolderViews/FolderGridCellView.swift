//
//  FolderGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI

struct FolderGridCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    let folder: Content
    
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
                viewModel.selectedContent = folder
            }
            if !viewModel.isSelectionMode {
                Button(action: {
                    viewModel.selectedContent = folder
                    viewModel.showModifyModal = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .frame(width: 44, height: 44)
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
            }
        )
    }
}
