//
//  ScoreSettingRowView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import SwiftUI

struct ScoreSettingRowView: View {
    @EnvironmentObject var viewModel : ScoreSettingViewModel
    let settingImageName : String
    let settingMessege : String
    
    var body: some View {
        Button(action: {
            // TODO: 한장씩 보기, 두 장씩 보기 기능 추가
            viewModel.toggle()
        }
        ){
            HStack(){
                Image(settingImageName)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .padding(.leading, 12.97)
                    .padding(.trailing, 19)
                Text(settingMessege)
                    .textStyle(.bodyTextXLMedium)
            }
            .foregroundColor(Color.primaryBaseBlack)
            .padding(.vertical, 8.84)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.primaryGray100) // TODO: 디자인 시스템 적용되면 바꾸기
    }
}



