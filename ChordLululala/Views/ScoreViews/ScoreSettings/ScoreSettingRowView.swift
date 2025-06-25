//
//  ScoreSettingRowView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import SwiftUI

struct ScoreSettingRowView: View {
    let settingImageName : String
    let settingMessege : String
    let action : () -> Void
    var body: some View {
        Button(action: action){
            HStack(){
                Image(settingImageName)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .padding(.leading, 12.97)
                    .padding(.trailing, 19)
                    .foregroundColor(Color.primaryBaseBlack)
                Text(settingMessege)
                    .textStyle(.bodyTextXLMedium)
                    .foregroundColor(Color.primaryBaseBlack)
                Spacer()
                
                if settingMessege == "페이지 레이아웃" || settingMessege == "페이지 회전" {
                    Image("arrow_right")
                        .resizable()
                        .frame(width: 19, height: 19)
                        .padding(.trailing, 12.97)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 36)
        }
    }
}



