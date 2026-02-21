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
        VStack(alignment: .leading) {
            Text("선택")
                .textStyle(.displayXLBold)
                .foregroundColor(Color.primaryGray900)
            
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
                        .foregroundColor(Color.primaryGray700)
                }
                
                Spacer()
                
                HStack(spacing: 27) {
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
                .disabled(viewModel.selectedContents.isEmpty)
                
                Spacer()
                
                Button(action: {
                    viewModel.selectedContents.removeAll()
                    viewModel.isSelectionViewVisible = false
                }) {
                    Text("완료")
                        .textStyle(.headingMdSemiBold)
                        .foregroundColor(Color.primaryGray700)
                }
            }
            .padding(.top, 33)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 151)
        .padding(.top, 16)
//        .padding(.horizontal, 43)
//        .background(Color.white)
    }
}
