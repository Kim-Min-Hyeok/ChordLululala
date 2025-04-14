//
//  DeleteModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/24/25.
//

import SwiftUI

struct DeleteModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    let content: ContentModel
    
    var body: some View {
        VStack(spacing: 0) {
            Button(role: .destructive) {
                viewModel.deleteContent(content)
            } label: {
                Label("영구적으로 삭제", image: "trash_destructive_context")
            }
            // 하위 항목은 복구 위치가 없기 때문에 복구 불가
            if viewModel.currentParent?.parentContent == nil {
                Button {
                    viewModel.restoreContent(content)
                } label: {
                    Label("복원", image: "restore_context")
                }
            }
        }
    }
}
