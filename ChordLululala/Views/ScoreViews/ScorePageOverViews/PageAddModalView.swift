//
//  PageAddModalView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct PageAddModalView: View {
    var body: some View {
        VStack(spacing: 0) {
            PageOverModalRowView(
                ImageName: "upload_image",
                Messege: "이미지"
            )
            
            Rectangle()
                .frame(height: 1)
                .background(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "upload_file",
                Messege: "파일"
            )
            
            Rectangle()
                .frame(height: 1)
                .background(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "add_blank",
                Messege: "백지 추가"
            )
            
            Rectangle()
                .frame(height: 1)
                .background(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "add_staff",
                Messege: "오선지 추가"
            )
        }
        .frame(width: 210)
        .background(Color.primaryBaseWhite)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)

    }
}
