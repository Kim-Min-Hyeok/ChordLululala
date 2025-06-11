//
//  PageOptionModalView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct PageOptionModalView: View {
    var deletePage: () -> Void
    var duplicatePage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            PageOverModalRowView(
                ImageName: "page_delete",
                Messege: "페이지 지우기",
                onSelect: {
                    deletePage()
                }
            )
            
            Rectangle()
                .frame(height: 1)
                .background(Color.primaryGray300)
            
            PageOverModalRowView(
                ImageName: "duplication_context",
                Messege: "복제",
                onSelect: {
                    duplicatePage()
                }
            )
        }
        .frame(width: 210)
        .background(Color.primaryBaseWhite)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)
    }
}
