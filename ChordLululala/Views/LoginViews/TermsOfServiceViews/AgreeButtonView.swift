//
//  AgreeButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/23/25.
//

import SwiftUI

struct AgreeButton<Content: View>: View {
    @Binding var isAgreed: Bool
    let content: () -> Content
    
    init(isAgreed: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isAgreed = isAgreed
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Image(systemName: "checkmark.square.fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundColor(isAgreed ? Color.primaryBlue600 : Color.primaryGray300)
            }
            .frame(width: 36, height: 36) // 탭 영역 설정
            .contentShape(Rectangle())   // 전체 영역이 탭 가능하도록
            .onTapGesture { //
                isAgreed.toggle()
            }
            content()
        }
    }
}
