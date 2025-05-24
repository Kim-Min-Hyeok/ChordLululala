//
//  ScorePageOverContentView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct ScorePageOverContentView: View {
    let pageIndex : Int  // TODO: 임시로 넣은 값 바꿔야 함
    var body: some View {
        VStack{
            //페이지
            Image(systemName: "circle.fill") // TODO: 이미지 바꿔야 함
                .resizable()

            
            HStack{
                Text("\(pageIndex)")
                    .textStyle(.headingLgSemiBold)
                Spacer()
                
                Button(action: {
                    //TODO: 모달 창 띄우기
                }){
                    Image("dropdown")
                        .resizable()
                        .frame(width: 10, height: 15)
                }
            }
            .foregroundColor(Color.primaryGray500)
        }
    }
}
