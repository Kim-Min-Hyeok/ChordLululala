//
//  ChordReconizeView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/10/25.
//

import SwiftUI

/// 악보인식뷰 
struct ChordReconizeView: View {
    @EnvironmentObject var router: NavigationRouter
    let file: ContentModel // ScoreView에서 전달해준 데이터

    var body: some View {
        ZStack {
            ///배경색
            Color.primaryGray50
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                /// 헤더
                HStack {
                    Button(action: {
                        router.offNamed("/score", arguments: [file])
                    }) {
                        Text("끝내기")
                            .textStyle(.headingLgSemiBold)
                            .foregroundColor(Color.supportingRed600)
                    }

                    Spacer()
                        .frame(width: 495)

                    HStack(spacing: 7) {
                        Image("scoreheader_loading")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21, height: 21)
                        Text("인식중")
                            .textStyle(.headingLgSemiBold)
                    }
                    .foregroundColor(Color.primaryBlue600)

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .frame(height: 83)
                .background(Color.primaryBaseWhite)

                /// 로딩 뷰
                LoadingView()
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
            }
        }
        .navigationBarHidden(true)
    }
}

