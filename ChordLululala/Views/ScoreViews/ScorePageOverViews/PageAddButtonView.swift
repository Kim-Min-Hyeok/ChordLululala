//
//  PageAddButtonView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct PageAddButtonView: View {
    @EnvironmentObject var vm : ScorePageOverViewModel
    var body: some View {
        
        Button(action:{
            vm.isAddPage() // 페이지 추가 버튼 클릭시
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 8.78)
                    .fill(Color.primaryBlue100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.78)
                            .stroke(style: StrokeStyle(lineWidth: 1.76, dash: [3]))
                            .foregroundColor(Color.primaryBlue600)
                    )
                
                // + 이미지
                ZStack {
                    Rectangle()
                        .frame(width: 2, height: 19.22)
                    Rectangle()
                        .frame(width: 19.31, height: 2)
                }
                .foregroundColor(Color.primaryBlue600)
                
                
            }
            .frame(width: 122, height: 152)
        }
    }
}
