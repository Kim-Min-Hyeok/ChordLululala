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
    var onEllipsisTapped: (CGRect) -> Void
    
    @State private var cellFrame: CGRect = .zero
    
    var body: some View {
        HStack(spacing: 0) {
            // 좌측 영역: 폴더 이미지와 텍스트 (전체 영역 onTap)
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
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            Button(action: {
                onEllipsisTapped(cellFrame)
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            .frame(width: 44, height: 44)
        }
        .frame(height: 54)
        .overlay(
            Divider()
                .frame(height: 1)
                .background(Color.gray),
            alignment: .bottom
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        self.cellFrame = geo.frame(in: .global)
                    }
            }
        )
    }
}
