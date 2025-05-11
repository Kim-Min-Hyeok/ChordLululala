//
//  RenameModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI

struct RenameModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    let content: ContentModel
    @FocusState private var isFocused: Bool
    
    @State private var name: String = ""
    private let originalName: String
    
    private let type: String
    
    init(content: ContentModel) {
        self.type = {
            switch content.type {
            case .score:
                return "파일"
            case .setlist:
                return "셋리스트"
            case .folder:
                return "폴더"
            }
        }()
        
        self.content = content
        let baseName = (content.name as NSString).deletingPathExtension
        self._name = State(initialValue: baseName)
        self.originalName = baseName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(type) 이름 변경")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 18)
            
            Text("이 \(type)의 새로운 이름을 입력하십시오.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            ZStack(alignment: .trailing) {
                TextField("이름 없음", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                
                if !name.isEmpty {
                    Button(action: {
                        name = ""
                    }) {
                        Image("cancel")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 31, height: 31)
                }
            }
            .padding(.horizontal, 27)
            .padding(.top, 18)
            
            Divider()
                .foregroundStyle(Color.primaryGray300)
                .padding(.top, 18)
            HStack {
                Button("취소") {
                    viewModel.isRenameModalVisible = false
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .foregroundStyle(Color.primaryGray300)
                
                Button("확인") {
                    if name != originalName {
                        viewModel.renameContent(content, newName: name)
                    }
                    viewModel.isRenameModalVisible = false
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 51)
        }
        .frame(width: 309)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primaryBaseWhite.opacity(0.9))
                .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}
