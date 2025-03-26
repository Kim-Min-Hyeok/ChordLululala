//
//  FolderListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    let folder: ContentModel
    
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == folder.cid }
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 18) {
                Image("folder")
                    .resizable()
                    .frame(width: 61.63, height: 48.44)
                    .padding(.top, 4)
                    .padding(.leading, 8)
                VStack(spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(folder.name)
                                .textStyle(.bodyTextXLSemiBold)
                                .foregroundStyle(Color.primaryGray800)
                            Text(folder.modifiedAt.dateFormatForList())
                                .textStyle(.bodyTextLgRegular)
                                .foregroundStyle(Color.primaryGray600)
                                .padding(.top, 3)
                        }
                        .padding(.top, 8)
                        Spacer()
                        if !viewModel.isSelectionViewVisible {
                            Button(action: {
                                
                            }) {
                                Image("star")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .padding(.top, 11)
                            Button(action: {
                                viewModel.selectedContent = folder
                                if viewModel.dashboardContents == .trashCan {
                                    viewModel.isDeletedModalVisible = true
                                }
                                else {
                                    viewModel.isModifyModalVisible = true
                                }
                            }) {
                                Image("more")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .padding(.top, 11)
                        }
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.primaryGray200)
                }
            }
            .frame(height: 61)
            .onTapGesture {
                if viewModel.isSelectionViewVisible {
                    toggleSelection()
                } else {
                    viewModel.currentParent = folder
                    viewModel.loadContents()
                }
            }
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
        .padding(.bottom, 11)
    }
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == folder.cid }
        } else {
            viewModel.selectedContents.append(folder)
        }
    }
}
