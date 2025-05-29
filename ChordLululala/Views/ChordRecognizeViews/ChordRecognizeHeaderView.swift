//
//  ChordRecognizeHeaderView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordRecognizeHeaderView: View {
    let state: RecognitionState
    let onBack: () -> Void
    let onFixingKey: () -> Void
    let onCreateBox: () -> Void
    let onFinalize: () -> Void

    var body: some View {
        HStack {
            // 왼쪽 버튼
            Button(action: onBack) {
                Text("끝내기")
                    .textStyle(.headingLgSemiBold)
                    .foregroundColor(.supportingRed600)
            }

            Spacer()

            // 오른쪽 버튼들
            if state == .keyFixing {
                Button(action: onFixingKey) {
                    HStack(alignment: .center, spacing: 6) {
                        Text("변환 진행하기")
                            .textStyle(.headingLgSemiBold)
                            .foregroundStyle(Color.primaryBaseWhite)
                        Image("export")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                    }
                    .frame(width: 140, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primaryBlue600)
                    )
                }
            }
            if [.chordFixing, .keyTranspostion].contains(state) {
                HStack(spacing: 15) {
                    Button(action: onCreateBox) {
                        Text("+ 코드 박스 생성")
                            .textStyle(.headingSmSemiBold)
                            .frame(width: 118, height: 42)
                            .foregroundStyle(Color.primaryBlue600)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primaryGray50)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primaryGray100, lineWidth: 1)
                            )
                    }

                    Button(action: onFinalize) {
                        Text("코드 확정")
                            .textStyle(.headingLgSemiBold)
                            .frame(width: 83, height: 42)
                            .foregroundStyle(Color.primaryBaseWhite)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primaryBlue600)
                            )
                    }
                }
            }
        }
        .overlay(
            HStack(spacing: 7) {
                if state == .recognition {
                    Image("scoreheader_loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                }
                Text(state == .recognition ? "인식중" : "인식 완료")
                    .textStyle(.headingLgSemiBold)
            }
            .foregroundColor(.primaryBlue600)
        )
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .frame(height: 83)
        .background(Color.primaryBaseWhite)
    }
}
