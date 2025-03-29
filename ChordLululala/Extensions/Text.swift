//
//  Text.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/25/25.
//

import SwiftUI

extension Text {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.additionalLineSpacing)
            .kerning(style.letterSpacing)
    }
}

// MARK: 사용법:
//Text("NoteFlow")
//    .textStyle(.headingXLBold)
