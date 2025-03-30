//
//  ModifyModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI

struct ModifyModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    let content: ContentModel
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.selectedContent = content
                viewModel.isRenameModalVisible = true
            } label: {
                Label("이름변경", image: "pencil_context")
            }
            Button {
                viewModel.toggleContentStared(content)
            } label: {
                Label(content.isStared ? "즐겨찾기 해제" : "즐겨찾기 추가", image: content.isStared ? "star_context" : "star_fill_context")
            }
            Button {
                viewModel.duplicateContent(content)
            } label: {
                Label("복제하기", image: "duplication_context")
            }
            Button {
                viewModel.moveContentToTrash(content)
            } label: {
                Label("휴지통으로 이동", image: "trash_context")
            }
        }
    }
}
