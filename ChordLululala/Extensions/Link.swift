//
//  Link.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/25/25.
//

import SwiftUI

extension Link {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.additionalLineSpacing)
            .kerning(style.letterSpacing)
    }
}
