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
    let transposedText: String
    var onDelete: (() -> Void)? = nil
    var onMove: ((CGPoint) -> Void)? = nil
    
    @State private var dragOffset: CGSize = .zero
    
    var scaledPosition: CGPoint {
        CGPoint(
            x: CGFloat(chord.x) * displaySize.width / originalSize.width,
            y: CGFloat(chord.y) * displaySize.height / originalSize.height
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(transposedText)
                .textStyle(.bodyTextXLRegular)
                .foregroundColor(Color.primaryBaseBlack)
                .padding(.horizontal, 9)
                .frame(height: 23)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "EFEFF0").opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "DCDCDC"), lineWidth: 1)
                )
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image("delete_code")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14)
                }
                .offset(x: -5, y: -6)
                .simultaneousGesture(DragGesture(minimumDistance: 0))
            }
        }
        .position(x: scaledPosition.x + dragOffset.width, y: scaledPosition.y + dragOffset.height)
        .highPriorityGesture( // 드래그를 최우선으로 인식
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    dragOffset = .zero
                    let newPos = CGPoint(
                        x: scaledPosition.x + value.translation.width,
                        y: scaledPosition.y + value.translation.height
                    )
                    onMove?(newPos)
                }
        )
    }
}
