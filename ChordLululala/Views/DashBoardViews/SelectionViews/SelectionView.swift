//
//  SelectionView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    var onMove: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if viewModel.selectedContents.count == viewModel.sortedContents.count {
                        viewModel.selectedContents.removeAll()
                    } else {
                        viewModel.selectedContents = viewModel.sortedContents
                    }
                }) {
                    Text("전체 선택")
                        .textStyle(.headingMdSemiBold)
                        .foregroundColor(Color.primaryGray900)
                }
                .padding([.top, .leading], 30)
                Spacer()
                Button(action: {
                    viewModel.isSelectionViewVisible = false
                }) {
                    Text("완료")
                        .textStyle(.headingMdSemiBold)
                        .foregroundColor(Color.primaryGray900)
                }
                .padding([.top, .trailing], 30)
            }
            
            HStack(spacing: 63) {
                SelectionOptionButton(imageBaseName: "copy_context", title: "복제") {
                    viewModel.duplicateSelectedContents()
                    viewModel.isSelectionViewVisible = false
                }
                SelectionOptionButton(imageBaseName: "move_context", title: "이동") {
                    onMove()
                }
                SelectionOptionButton(imageBaseName: "trash_context", title: "휴지통") {
                    viewModel.isTrashModalVisible = true
                }
            }
            .padding(.top, -2)
            .disabled(viewModel.selectedContents.isEmpty)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 151)
        .background(Color.white)
    }
}
