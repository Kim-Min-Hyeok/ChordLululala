//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    let file: Content

    @State private var cellFrame: CGRect = .zero

    var body: some View {
        HStack() {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext")
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.black)
                Text(file.name ?? "Unnamed")
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectedContent = file
            }
            if !viewModel.isSelectionMode {
                Button(action: {
                    viewModel.selectedContent = file
                    viewModel.showModifyModal = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .frame(width: 44, height: 44)
            }
        }
        .frame(height: 54)
        .overlay(
            Divider()
                .frame(height: 1)
                .background(Color.gray),
            alignment: .bottom
        )
        .background(
            // GeometryReader를 사용해 셀 전체의 global frame을 캡처
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
            }
        )
    }
}
