//
//  ColorLabelStyle.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 4/4/25.
//

import SwiftUI

struct ColoredLabelStyle: LabelStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(color)
            configuration.title
                .foregroundColor(color)
        }
    }
}
