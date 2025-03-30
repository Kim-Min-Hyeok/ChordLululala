//
//  SelectionView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.selectedContents.append(contentsOf: viewModel.sortedContents)
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
                SelectionOptionButton(imageName: "copy_context", title: "복제", action: {
                    viewModel.duplicateSelectedContents()
                    viewModel.isSelectionViewVisible = false
                })
                SelectionOptionButton(imageName: "move_context", title: "보내기", action: {
                    viewModel.isSelectionViewVisible = false
                })
                SelectionOptionButton(imageName: "trash_context", title: "휴지통", action: {
                    viewModel.isTrashModalVisible = true
                })
            }
            .padding(.top, -2)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 151)
        .background(Color.white)
    }
}
