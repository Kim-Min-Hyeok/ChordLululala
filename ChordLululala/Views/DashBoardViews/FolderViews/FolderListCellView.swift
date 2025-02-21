//
//  FolderListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListCellView: View {
    let folder: Content
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.blue)
                Text(folder.name ?? "Unnamed")
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            // 버튼 내용의 높이를 52로 설정하여, 아래에 Divider를 오버레이할 공간 확보
            .frame(height: 53)
        }
        .buttonStyle(PlainButtonStyle())
        // 전체 셀의 높이를 53로 고정하고, 하단에 1포인트 Divider를 오버레이
        .frame(height: 54)
        .overlay(
            Divider()
                .frame(height: 1)
                .background(Color.gray),
            alignment: .bottom
        )
    }
}
