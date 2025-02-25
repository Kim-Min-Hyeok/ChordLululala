//
//  ModifyModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/22/25.
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
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow)
                .shadow(radius: 5)
            
            VStack(spacing: 18.71) {
                // 텍스트 필드 영역
                TextField("이름없음", text: $name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 9)
                    .frame(height: 37.29)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8.11)
                
                // 옵션 버튼 영역
                VStack(spacing: 0) {
                    Button(action: {
                        viewModel.isModifyModalVisible = false
                            viewModel.duplicateContent(content)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.black)
                            Text("복제하기")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                    }
                    Divider()
                    Button(action: {
                        viewModel.moveContentToTrash(content)
                        viewModel.isModifyModalVisible = false
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("휴지통으로 이동")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                    }
                }
                .background(Color.white)
                .cornerRadius(9.73)
            }
            .padding(.horizontal, 9)
            .padding(.top, 14)
            .padding(.bottom, 17.9)
        }
        .onDisappear() {
            // MARK:  모달이 dismiss될 때, 텍스트필드 값이 변경되었다면 onRename 호출 (이름 수정용)
            if name != originalName {
                viewModel.renameContent(content, newName: name)
            }
        }
    }
}
