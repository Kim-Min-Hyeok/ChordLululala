//
//  ScoreSettingView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import SwiftUI

enum ScoreSettingState {
    case base
    case layout
    case rotation
}

/// 힌페이지 or 두 페이지씩 보기 설정 UI
struct ScoreSettingView : View {
    @State var scoreSettingState: ScoreSettingState = .base
    
    // For base
    let deletePage: () -> Void
    
    // For layout
    let showSinglePage: () -> Void
    let showMultiPages: () -> Void
    
    // For rotation
    let rotateWithClockwise: () -> Void
    let rotateWithCounterClockwise: () -> Void
    
    var body: some View {
        VStack(spacing: 0){
            ZStack(alignment: .leading) {
                
                Text(scoreSettingState != .layout ? "설정" : "페이지 레이아웃")
                    .textStyle(.bodyTextXLMedium)
                    .foregroundColor(Color.primaryBaseBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8.84)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.primaryBaseWhite, scoreSettingState == .base ? Color.primaryBaseWhite : Color.primaryGray200]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                
                if scoreSettingState != .base {
                    Button(action: {
                        scoreSettingState = .base
                    }) {
                        Image("arrow_left")
                            .resizable()
                            .frame(width: 19, height: 19)
                    }
                }
            }
            
            
            Divider()
                .background(Color.primaryGray400)

            switch scoreSettingState {
            case .base:
                ScoreSettingRowView(
                    settingImageName: "score_multi",
                    settingMessege: "페이지 레이아웃",
                    action: {
                        scoreSettingState = .layout
                    }
                )
            case .layout:
                ScoreSettingRowView(
                    settingImageName: "score_single",
                    settingMessege: "한 페이지 보기",
                    action: {
                        showSinglePage()
                    }
                )
            case .rotation:
                ScoreSettingRowView(
                    settingImageName: "page_rotate",
                    settingMessege: "시계방향 90",
                    action: {
                        rotateWithClockwise()
                    }
                )
            }
    
            Divider()
                .background(Color.primaryGray400)

            switch scoreSettingState {
            case .base:
                ScoreSettingRowView(
                    settingImageName: "page_rotate",
                    settingMessege: "페이지 회전",
                    action:  {
                        scoreSettingState = .rotation
                    }
                )
            case .layout:
                ScoreSettingRowView(
                    settingImageName: "score_multi",
                    settingMessege: "여러 페이지 보기",
                    action:  {
                        showMultiPages()
                    }
                )
            case .rotation:
                ScoreSettingRowView(
                    settingImageName: "page_rotate_reversed",
                    settingMessege: "반시계방향 90",
                    action:  {
                        rotateWithCounterClockwise()
                    }
                )
            }
            
            Divider()
                .background(Color.primaryGray400)
            
            switch scoreSettingState {
            case .base:
                ScoreSettingRowView(
                    settingImageName: "page_delete",
                    settingMessege: "페이지 지우기",
                    action:  {
                        deletePage()
                    }
                )
            case .layout, .rotation:
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 36)
                    .foregroundStyle(Color.primaryGray50)
            }
        }
        .background(Color.primaryGray50)
        .frame(width: 210)
        .cornerRadius(9)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15) , radius: 10)
    }
}
