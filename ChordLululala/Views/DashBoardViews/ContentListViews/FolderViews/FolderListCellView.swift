//
//  FolderListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    let folder: Content
    
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == folder.cid }
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
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
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionMode {
                        toggleSelection()
                    } else {
                        viewModel.currentParent = folder
                        viewModel.loadContents()
                    }
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
            .frame(height: 54)
            .overlay(
                Divider()
                    .frame(height: 1)
                    .background(Color.gray),
                alignment: .bottom
            )
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
                }
            )
            if viewModel.isSelectionMode {
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
