//
//  AddPageModalView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/6/25.
//

import SwiftUI

struct AddPageModalView: View {
    let onSelect: (PageType) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("새 페이지 생성")
                .font(.headline)
            
            HStack(spacing: 32) {
                // 백지 선택
                VStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 100, height: 140)
                        .border(Color.gray)
                    Button("백지") {
                        onSelect(.blank)
                    }
                    .padding(.top, 8)
                }

            
                VStack {
                    Image("staff_template")
                        .resizable()
                        .frame(width: 100, height: 140)
                        .border(Color.gray)
                    Button("오선지") {
                        onSelect(.staff)
                    }
                    .padding(.top, 8)
                    
                }
            }
            
            Spacer()
            
            Button("닫기") {
                dismiss()
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}

