//
//  ChordResetModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/14/25.
//

import SwiftUI

struct ChordResetModalView: View {
    let onDismiss: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("정말 초기화하시겠어요?")
                .textStyle(.headingMdSemiBold)
                .foregroundStyle(Color.primaryGray900)
            Text("코드 변경 전 파일로 돌아갑니다.")
                .textStyle(.bodyTextLgRegular)
                .foregroundStyle(Color.primaryGray500)
                .padding(.top, 8)
            Spacer()
            Divider()
                .background(Color.primaryGray300)
                .frame(height: 1)
            HStack {
                Button(action: {
                    onDismiss()
                }) {
                    Text("취소")
                        .textStyle(.headingLgMedium)
                        .foregroundColor(.primaryBlue600)
                        .frame(maxWidth: .infinity, maxHeight: 51)
                                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 20)
                Divider()
                    .background(Color.primaryGray300)
                    .frame(width: 1)
                Button(action: {
                    onReset()
                }) {
                    Text("확인")
                        .textStyle(.headingLgMedium)
                        .foregroundColor(.primaryBlue600)
                        .frame(maxWidth: .infinity, maxHeight: 51)
                                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 51)
        }
        .frame(width: 309, height: 135)
        .background(Color.primaryBaseWhite.opacity(0.9))
        .cornerRadius(10)
    }
}
