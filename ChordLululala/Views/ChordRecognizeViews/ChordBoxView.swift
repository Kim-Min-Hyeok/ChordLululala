//
//  ChordBoxView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import SwiftUI

struct ChordBoxView: View {
    let chord: ScoreChordModel
    let originalSize: CGSize
    let displaySize: CGSize

    var body: some View {
        Text(chord.chord)
            .font(.caption)
            .foregroundColor(.red)
            .padding(4)
            .background(Color.white.opacity(0.7))
            .cornerRadius(4)
            .position(
                x: CGFloat(chord.x) * displaySize.width / originalSize.width,
                y: CGFloat(chord.y) * displaySize.height / originalSize.height
            )
    }
}
