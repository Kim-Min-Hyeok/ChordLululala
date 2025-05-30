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
    let action : () -> Void
    var body: some View {
        Button(action: action){
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
        .background(Color.primaryGray100)
    }
}



