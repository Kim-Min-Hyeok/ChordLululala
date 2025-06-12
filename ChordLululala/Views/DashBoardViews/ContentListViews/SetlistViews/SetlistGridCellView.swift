//
//  SetlistGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/22/25.
//

import SwiftUI

struct SetlistGridCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @EnvironmentObject var router: NavigationRouter
    @State private var cellFrame: CGRect = .zero
    
    let setlist: ContentModel
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == setlist.cid }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            if viewModel.isSelectionViewVisible {
                Image(isSelected ? "selected" : "not_selected")
                    .resizable()
                    .frame(width: 25.41, height: 25.41)
                    .padding(.bottom, 6)
            }
            ZStack (alignment: .bottomLeading) {
                Image("setlist3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 121)
                Button(action: {
                    viewModel.toggleContentStared(setlist)
                }) {
                    Image(setlist.isStared ? "star_fill" : "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.bottom, 3)
                        .padding(.leading, 3)
                }
                .disabled(viewModel.isSelectionViewVisible)
            }
            .frame(width: viewModel.isLandscape ? 200 : 171, height: 114)
            VStack (spacing: 3){
                Text(setlist.name)
                    .textStyle(.bodyTextXLSemiBold)
                    .foregroundStyle(Color.primaryGray800)
                Text(setlist.modifiedAt.dateFormatForGrid())
                    .textStyle(.bodyTextLgRegular)
                    .foregroundStyle(Color.primaryGray600)
                if viewModel.isSearching {
                    Text(viewModel.getParentName(of: setlist))
                            .textStyle(.bodyTextLgRegular)
                            .foregroundStyle(Color.primaryBlue600)
                            .padding(.top, 3)
                } else {
                    Spacer()
                }
            }
            .frame(width: viewModel.isLandscape ? 200 : 171, height: 61)
        }
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
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == setlist.cid }
        } else {
            viewModel.selectedContents.append(setlist)
        }
    }
}
