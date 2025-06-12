//
//  SetlistListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/22/25.
//

import SwiftUI

struct SetlistListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @EnvironmentObject var router: NavigationRouter
    let setlist: ContentModel
    
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == setlist.cid }
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 18) {
                if viewModel.isSelectionViewVisible {
                    HStack {
                        Image(isSelected ? "selected" : "not_selected")
                            .resizable()
                            .frame(width: 25.41, height: 25.41)
                            .padding(.bottom, 1.59)
                    }
                    .frame(maxHeight: .infinity)
                }
                VStack {
                    Image("setlist3")
                        .resizable()
                        .frame(width: 61.63, height: 48.44)
                        .padding(.top, 4)
                }
                .frame(width: 78, height: 57)
                VStack(spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(setlist.name)
                                .textStyle(.bodyTextXLSemiBold)
                                .foregroundStyle(Color.primaryGray800)
                            Text(setlist.modifiedAt.dateFormatForList())
                                .textStyle(.bodyTextLgRegular)
                                .foregroundStyle(Color.primaryGray600)
                                .padding(.top, 3)
                        }
                        .padding(.top, 8)
                        Spacer()
                        if !viewModel.isSelectionViewVisible {
                            Button(action: {
                                viewModel.toggleContentStared(setlist)
                            }) {
                                Image(setlist.isStared ? "star_fill" : "star")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .padding(.top, 11)
                            .disabled(viewModel.isSelectionViewVisible)
                        }
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.primaryGray200)
                }
            }
            .frame(height: 61)
            .padding(.bottom, 11)
            .onTapGesture {
                if viewModel.isSelectionViewVisible {
                    toggleSelection()
                } else {
                    router.toNamed("/score", arguments: [setlist])
                }
            }
            .conditionalContextMenu(isEnabled: !viewModel.isSelectionViewVisible) {
                if viewModel.dashboardContents == .trashCan {
                    DeleteModalView(content: setlist)
                } else {
                    FileContextMenuView(content: setlist)
                }
            }
        }
    }
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == setlist.cid }
        } else {
            viewModel.selectedContents.append(setlist)
        }
    }
}
