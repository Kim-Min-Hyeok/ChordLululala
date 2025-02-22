//
//  ModifyModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/22/25.
//

import SwiftUI

struct ModifyModalView: View {
    let content: Content
    var onDismiss: () -> Void
    @State private var name: String

    init(content: Content, onDismiss: @escaping () -> Void) {
        self.content = content
        self.onDismiss = onDismiss
        _name = State(initialValue: content.name ?? "")
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
                    Button(action: { onDismiss() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.black)
                            Text("내보내기")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                    }
                    Divider()
                    Button(action: { onDismiss() }) {
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
                    Button(action: { onDismiss() }) {
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
    }
}
