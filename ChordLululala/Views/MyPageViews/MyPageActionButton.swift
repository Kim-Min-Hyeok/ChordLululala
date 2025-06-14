//
//  MyPageActionButton.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/14/25.
//

import SwiftUI

struct MypageActionButton<TrailingView: View>: View {
    let iconName: String
    let title: String
    let trailingView: TrailingView
    let onTap: () -> Void

    @State private var isPressed = false

    init(
        iconName: String,
        title: String,
        @ViewBuilder trailingView: () -> TrailingView,
        onTap: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.trailingView = trailingView()
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .padding(.leading, 24)

                Text(title)
                    .textStyle(.headingMdSemiBold)
                    .foregroundStyle(Color.primaryGray800)
                    .padding(.leading, 8)

                Spacer()

                trailingView
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isPressed ? Color.primaryGray100 : Color.primaryBaseWhite)
        .cornerRadius(5)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
