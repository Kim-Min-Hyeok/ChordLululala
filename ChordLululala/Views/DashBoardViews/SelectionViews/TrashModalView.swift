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
        VStack(spacing: 16) {
            Text("휴지통으로 이동하시겠습니까?")
                .font(.headline)
                .padding(.top, 16)
            
            Text("'파일명'이 30일 후 완전삭제됩니다.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            HStack {
                Button(action: {
                    viewModel.showTrashModal = false
                }) {
                    Text("취소")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.moveSelectedContentsToTrash()
                    viewModel.showTrashModal = false
                    viewModel.isSelectionMode = false
                }) {
                    Text("확인")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}
