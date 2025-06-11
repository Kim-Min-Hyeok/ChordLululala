//
//  PageAddModalView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct PageAddModalView: View {
    var addImage: () -> Void
    var addFile: () -> Void
    var addBlank: () -> Void
    var addStaff: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            PageOverModalRowView(
                ImageName: "upload_image",
                Messege: "이미지",
                onSelect: {
                    addImage()
                }
            )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "upload_file",
                Messege: "파일",
                onSelect: {
                    addFile()
                }
            )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "add_blank",
                Messege: "백지 추가",
                onSelect: {
                    addBlank()
                }
            )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "add_staff",
                Messege: "오선지 추가",
                onSelect: {
                    addStaff()
                }
            )
        }
        .frame(width: 210)
        .background(Color.primaryBaseWhite)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)

    }
}
