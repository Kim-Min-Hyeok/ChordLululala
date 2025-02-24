//
//  FolderGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI

struct FolderGridCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @State private var cellFrame: CGRect = .zero
    
    let folder: Content
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == folder.cid }
    }
    
    var body: some View {
        ZStack {
            HStack {
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
                    if viewModel.isSelectionViewVisible {
                        toggleSelection()
                    } else {
                        viewModel.currentParent = folder
                        viewModel.loadContents()
                    }
                }
                if !viewModel.isSelectionViewVisible {
                    Button(action: {
                        viewModel.selectedContent = folder
                        viewModel.isModifyModalVisible = true
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
                    Color.clear.onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
                }
            )
            if viewModel.isSelectionViewVisible {
                HStack {
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 9)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection()
                }
            }
        }
    }
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == folder.cid }
        } else {
            viewModel.selectedContents.append(folder)
        }
    }
}
