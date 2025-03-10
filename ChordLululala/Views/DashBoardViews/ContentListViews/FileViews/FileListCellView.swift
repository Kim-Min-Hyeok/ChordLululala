//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @EnvironmentObject var router: NavigationRouter
    let file: ContentModel
    
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == file.cid }
    }
    
    var body: some View {
        ZStack {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "doc.richtext")
                        .resizable()
                        .frame(width: 53, height: 53)
                        .foregroundColor(.black)
                    Text(file.name)
                        .font(.body)
                        .foregroundColor(.black)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionViewVisible {
                        toggleSelection()
                    } else {
                        // 나중에 송리스트에서도 동일한 방식 사용하기 위해 배열로 전달
                        router.toNamed("/score", arguments: [file])
                    }
                }
                if !viewModel.isSelectionViewVisible {
                    Button(action: {
                        viewModel.selectedContent = file
                        if viewModel.dashboardContents == .trashCan {
                            viewModel.isDeletedModalVisible = true
                        }
                        else {
                            viewModel.isModifyModalVisible = true
                        }
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
            viewModel.selectedContents.removeAll { $0.cid == file.cid }
        } else {
            viewModel.selectedContents.append(file)
        }
    }
}
