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
    
    @State private var name: String
    
    private let originalName: String
    
    init(content: ContentModel) {
        self.content = content
        
        // 파일인 경우 확장자(.pdf)가 있다면 제거해서 보여줌
        if content.type.rawValue != 2 {
            let baseName = (content.name as NSString).deletingPathExtension
            _name = State(initialValue: baseName)
            self.originalName = baseName
        } else {
            _name = State(initialValue: content.name)
            self.originalName = content.name
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
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
                viewModel.isModifyModalVisible = false
            } label: {
                Label("휴지통으로 이동", image: "trash_context")
            }
        }
    }
}
