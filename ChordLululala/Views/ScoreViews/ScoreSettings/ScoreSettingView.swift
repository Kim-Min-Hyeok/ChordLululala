//
//  ScoreSettingView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import SwiftUI

/// 힌페이지 or 두 페이지씩 보기 설정 UI
struct ScoreSettingView : View {
    let showSinglePage: () -> Void
    let showMultiPages: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0){
            Text("설정")
                .textStyle(.bodyTextXLMedium)
                .foregroundColor(Color.primaryBaseBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8.84)
                .background(Color.primaryBaseWhite)
            
            Divider()
                .background(Color.primaryGray400)

            
            ScoreSettingRowView(
                settingImageName: "score_single",
                settingMessege: "한 페이지 보기",
                action: {
                    showSinglePage()
                }
            )
            .background(Color.primaryGray50)
    
            Divider()
                .background(Color.primaryGray400)

            ScoreSettingRowView(
                settingImageName: "score_multi",
                settingMessege: "여러 페이지 보기",
                action:  {
                    showMultiPages()
                }
            )
            .background(Color.primaryGray100)

        }
        .frame(width: 210)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)
    }
}
