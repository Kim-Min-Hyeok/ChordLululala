//
//  PageOptionModalView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct PageOptionModalView: View {
    var body: some View {
        VStack(spacing: 0) {
            PageOverModalRowView(
                ImageName: "page_rotate",
                Messege: "페이지 회전"
            )
            
            Rectangle()
                .frame(height: 1)
                .background(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "page_delete",
                Messege: "페이지 지우기"
            )
        }
        .frame(width: 210)
        .background(Color.primaryBaseWhite)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)


    }
}
