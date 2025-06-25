//
//  BackupAndImportButton.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/13/25.
//

import SwiftUI

struct BackupAndImportButton: View {
    let imageName: String
    let title: String
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)

            Text(title)
                .textStyle(.bodyTextXLSemiBold)
                .foregroundColor(.primaryGray800)
        }
        .frame(maxWidth: 120, minHeight: 42)
        .background(isPressed ? Color.primaryGray200 : Color.primaryGray100)
        .cornerRadius(200)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    action()
                }
        )
    }
}
