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
            // 하위 항목은 복구 위치가 없기 때문에 복구 불가
            if viewModel.currentParent?.parentContent == nil {
                Button {
                    viewModel.restoreContent(content)
                } label: {
                    Label("복구하기", image: "doc.on.doc")
                }
            }
            Button {
                viewModel.deleteContent(content)
            } label: {
                Label("즉시삭제", image: "trash_context")
            }
        }
    }
}
