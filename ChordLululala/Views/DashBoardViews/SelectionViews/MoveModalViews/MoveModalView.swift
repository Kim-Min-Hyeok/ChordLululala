//
//  MoveModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 4/30/25.
//

import SwiftUI

struct MoveModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    var body: some View {
        let dest = viewModel.selectedDestination
        let isDisabled = dest == nil || dest?.cid == viewModel.currentParent?.cid
        
        VStack(spacing: 0) {
            Text("파일 이동")
                .textStyle(.headingMdSemiBold)
                .foregroundStyle(Color.primaryGray900)
                .padding(.vertical, 18)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.moveDestinations.filter { $0.type == .folder }, id: \.cid) { folder in
                        MoveFolderButtonView(
                            folder: folder,
                            isSelected: dest?.cid == folder.cid
                        ) {
                            viewModel.selectedDestination = folder
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 253)
            Divider()
                .foregroundStyle(Color.primaryGray300)
            HStack {
                Button {
                    viewModel.isMoveModalVisible = false
                    viewModel.selectedDestination = nil
                } label: {
                    Text("취소")
                        .textStyle(.headingLgMedium)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .foregroundColor(.primaryBlue600)
                
                Divider()
                    .frame(height: 44)
                    .foregroundStyle(Color.primaryGray300)
                
                Button {
                    guard let destination = dest else { return }
                    viewModel.moveSelectedContents(to: destination)
                } label: {
                    Text("이동")
                        .textStyle(.headingLgMedium)
                    // 레이블 전체를 영역으로
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .foregroundColor(isDisabled
                                 ? .primaryGray300
                                 : .primaryBlue600)
                .disabled(isDisabled)
            }
            .frame(height: 51)
        }
        .frame(maxWidth: 309)
        .background(Color.white.opacity(0.90))
        .cornerRadius(10)
        .shadow(radius: 8)
    }
}
