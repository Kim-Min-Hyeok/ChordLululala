//
//  PageAddButtonView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct PageAddButtonView: View {
    var toggleOptions: () -> Void
    
    var body: some View {
        HStack {
            Button(action:{
                toggleOptions()
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
                .padding(.bottom ,20)
            }
        }
        .frame(width: 160, height: 191)
    }
}
