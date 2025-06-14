//
//  TrashModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct TrashModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("휴지통으로 이동하시겠습니까?")
                .textStyle(.headingMdSemiBold)
                .foregroundStyle(Color.primaryGray900)
                .padding(.top, 18)
            
            Text("30일 후 영구적으로 자동 삭제됩니다.")
                .textStyle(.bodyTextLgRegular)
                .foregroundStyle(Color.primaryGray500)
                .padding(.top, 8)
                .padding(.horizontal, 16)
            
            HStack(spacing: 0) {
                Button(action: {
                    viewModel.isTrashModalVisible = false
                }) {
                    Text("취소")
                        .font(.headingLgMedium)
                        .frame(width: 154, height: 50)
                }
                .foregroundColor(.primaryBlue600)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.primaryGray300),
                    alignment: .top
                )

                Button(action: {
                    viewModel.moveSelectedContentsToTrash()
                    viewModel.isTrashModalVisible = false
                    viewModel.isSelectionViewVisible = false
                }) {
                    Text("확인")
                        .font(.headingLgSemiBold)
                        .frame(width: 155, height: 50)
                }
                .foregroundColor(.supportingRed500)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.primaryGray300),
                    alignment: .top
                )
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.primaryGray300),
                    alignment: .leading
                )
            }
            .padding(.top, 18)
        }
        .frame(width: 309)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
    }
}
