//
//  PageIndicatorView.swift
//  ChordLululala
//
//  Created by 김민준 on 4/30/25.
//

import SwiftUI

/// 페이지 인디케이터
struct PageIndicatorView : View {
    let current : Int
    let total : Int
    var body: some View {
        Text("\(current) / \(total)")
            .textStyle(.headingLgSemiBold)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(Color.primaryBaseWhite)
            .cornerRadius(19)
            .foregroundColor(Color.init(hex: "#838383"))
            .shadow(
                color: Color.primaryBaseBlack.opacity(0.25),
                radius: 30,
                x: 0,
                y: 0
            )
            

    }
}
