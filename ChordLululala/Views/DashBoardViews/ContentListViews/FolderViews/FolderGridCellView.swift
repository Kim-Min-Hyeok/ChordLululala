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
    
    let folder: ContentModel
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == folder.cid }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                VStack {
                    ZStack (alignment: .bottomLeading) {
                        Image("folder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 121)
                        if !viewModel.isSelectionViewVisible {
                            Button(action: {
                                viewModel.toggleContentStared(folder)
                            }) {
                                Image(folder.isStared ? "star_fill" : "star")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.bottom, 3)
                                    .padding(.leading, 3)
                            }
                        }
                    }
                }
                .frame(width: viewModel.isLandscape ? 200 : 171, height: 114)
                VStack (spacing: 3){
                    Text(folder.name)
                        .textStyle(.bodyTextXLSemiBold)
                        .foregroundStyle(Color.primaryGray800)
                    Text(folder.modifiedAt.dateFormatForGrid())
                        .textStyle(.bodyTextLgRegular)
                        .foregroundStyle(Color.primaryGray600)
                    Spacer()
                }
                .frame(width: viewModel.isLandscape ? 200 : 171, height: 61)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
                }
            )
            .onTapGesture {
                if viewModel.isSelectionViewVisible {
                    toggleSelection()
                } else {
                    viewModel.currentParent = folder
                    viewModel.loadContents()
                }
            }
            .contextMenu {
                if viewModel.dashboardContents == .trashCan {
                    DeleteModalView(content: folder)
                } else {
                    ModifyModalView(content: folder)
                }
            }
        }
        if viewModel.isSelectionViewVisible {
            HStack {
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
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == folder.cid }
        } else {
            viewModel.selectedContents.append(folder)
        }
    }
}
