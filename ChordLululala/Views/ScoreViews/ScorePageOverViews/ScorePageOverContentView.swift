//
//  ScorePageOverContentView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct CellFrameKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

import SwiftUI

struct ScorePageOverContentView: View {
    let pageIndex: Int
    let image: UIImage
    let rotate: Int
    let onToggleOptions: (Int) -> Void
    
    private var imageSize: CGSize {
        if rotate % 2 == 0 {
            // 0°, 180° → portrait
            return CGSize(width: 99, height: 135)
        } else {
            // 90°, 270° → landscape
            return CGSize(width: 135, height: 99)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.width, height: imageSize.height)
                .rotationEffect(
                    Angle(degrees: Double(rotate) * 90),
                    anchor: .center
                )
                .cornerRadius(1)
                .shadow(color: Color.primaryBaseBlack.opacity(0.25), radius: 3.24, x: 0, y: 3.24)
            
            HStack {
                Text("\(pageIndex+1)")
                    .textStyle(.headingLgSemiBold)
                Spacer()
                Button {
                    onToggleOptions(pageIndex)
                } label: {
                    Image("dropdown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 15)
                }
            }
            .frame(width: 129, height: 24)
            .foregroundColor(Color.primaryGray500)
        }
        .frame(width: 160, height: 191)
        .background {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: CellFrameKey.self,
                        value: [pageIndex: geo.frame(in: .named("scrollArea"))]
                    )
            }
        }
    }
}
