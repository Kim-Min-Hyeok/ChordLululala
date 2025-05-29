//
//  ChordPagePreviewView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordPagePreviewView: View {
    let image: UIImage
    let chords: [ScoreChordModel]
    let transposed: (String) -> String

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)

                ForEach(chords, id: \.s_cid) { chord in
                    let posX = CGFloat(chord.x) * geo.size.width / image.size.width
                    let posY = CGFloat(chord.y) * geo.size.height / image.size.height

                    Text(transposed(chord.chord))
                        .textStyle(.bodyTextLgRegular)
                        .foregroundColor(.primaryBaseBlack)
                        .position(x: posX, y: posY)
                }
            }
        }
        .frame(width: 234.54, height: 300.8)
        .shadow(color: Color.primaryBaseBlack.opacity(0.25), radius: 13.14, x: 0, y: 3.5)
        .navigationBarHidden(true)
    }
}
