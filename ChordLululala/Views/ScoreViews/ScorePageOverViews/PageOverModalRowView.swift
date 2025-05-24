//
//  PageOverModalRowView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct PageOverModalRowView: View {
    let ImageName: String
    let Messege: String
    
    var body: some View {
        Button(action:{
            // TODO: 페이지 지우기, 회전하기 기능 추가하기
        }){
            HStack(){
                Image(ImageName)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .padding(.leading, 12.97)
                    .padding(.trailing, 19)
                Text(Messege)
                    .textStyle(.bodyTextXLMedium)
                    .foregroundColor(Color.primaryGray900)
            }
            .padding(.vertical, 8.84)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.primaryBaseWhite)
    }
}
