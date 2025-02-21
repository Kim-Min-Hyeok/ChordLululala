//
//  FloatingMenuButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FloatingMenuView: View {
    let folderAction: () -> Void
    let fileUploadAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            FloatingMenuButton(icon: "folder.fill.badge.plus", title: "폴더 만들기", action: folderAction)
            Divider()
            FloatingMenuButton(icon: "square.and.arrow.up", title: "파일 업로드", action: fileUploadAction)
        }
        .background(Color.white)
        .cornerRadius(9.73)
        .frame(width: 210, height: 72)
        .shadow(radius: 1)
    }
}

struct FloatingMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack() {
                Image(systemName: icon)
                    .font(.system(size: 19))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                    .padding(.vertical, 8.34)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.leading, 19)
                
                Spacer()
            }
        }
    }
}
