//
//  MultiImageView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/30/25.
//

import SwiftUI

struct MultiImageView: View {
    let uiImage: UIImage

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero

    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .shadow(radius: 4)
            .padding(.vertical)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                        .onEnded { _ in },
                    DragGesture()
                        .onChanged { drag in
                            offset = drag.translation
                        }
                        .onEnded { _ in }
                )
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut) {
                    scale = 1
                    offset = .zero
                }
            }
    }
}

