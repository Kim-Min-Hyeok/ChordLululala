//
//  CreateFolderModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI

struct CreateFolderModalView: View {
    @Binding var isPresented: Bool
    @State private var folderName: String = ""
    
    // 현재 부모 폴더 (nil이면 루트)
    var currentParent: ContentModel?
    // 폴더 생성 후 호출되는 콜백: 폴더 이름과 현재 부모 전달
    var onCreate: (String, ContentModel?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 영역
            HStack {
                Button("취소") {
                    isPresented = false
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Text("새폴더")
                    .font(.headline)
                
                Spacer()
                
                Button("만들기") {
                    if !folderName.isEmpty {
                        onCreate(folderName, currentParent)
                        isPresented = false
                    }
                }
                .padding(.trailing, 10)
            }
            .padding(.vertical, 10)
            
            Divider()
            
            // 폴더 이름 입력 텍스트필드
            TextField("폴더 이름 작성", text: $folderName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Spacer()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}
