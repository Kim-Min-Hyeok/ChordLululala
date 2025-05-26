//
//  FloatingMenuButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FloatingMenuView: View {
    @EnvironmentObject private var viewModel: DashBoardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.dashboardContents == .score {
                FloatingMenuButton(icon: "album", title: "이미지 업로드", action: {
                    withAnimation {
                        viewModel.isFloatingMenuVisible.toggle()
                        viewModel.isAlbumPickerVisible = true
                    }
                })
                Divider()
                FloatingMenuButton(icon: "upload", title: "파일 업로드", action: {
                    withAnimation {
                        viewModel.isFloatingMenuVisible.toggle()
                        viewModel.isPDFPickerVisible = true
                    }
                })
                if viewModel.currentParent?.parentContent == nil {
                    Divider()
                        .frame(height: 0.32)
                        .foregroundStyle(Color.primaryGray300)
                    FloatingMenuButton(icon: "folder2", title: "폴더 만들기", action: {
                        withAnimation {
                            viewModel.isFloatingMenuVisible.toggle()
                            viewModel.isCreateFolderModalVisible = true
                        }
                    })
                }
            }
            else if viewModel.dashboardContents == .setlist {
                FloatingMenuButton(icon: "setlist2", title: "셋리스트 생성", action: {
                    withAnimation {
                        viewModel.isFloatingMenuVisible.toggle()
                        viewModel.isCreateSetlistModalVisible = true
                    }
                })
                if viewModel.currentParent?.parentContent == nil {
                    Divider()
                        .frame(height: 0.32)
                        .foregroundStyle(Color.primaryGray300)
                    FloatingMenuButton(icon: "folder2", title: "폴더 만들기", action: {
                        withAnimation {
                            viewModel.isFloatingMenuVisible.toggle()
                            viewModel.isCreateFolderModalVisible = true
                        }
                    })
                }
            }
        }
        .background(Color.primaryBaseWhite)
        .cornerRadius(13)
        .frame(width: 210)
    }
}

struct FloatingMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 12.97)
                    .padding(.vertical, 5.84)
                Text(title)
                    .textStyle(.headingSmMedium)
                    .foregroundColor(Color.primaryGray900)
                    .padding(.leading, 19)
                Spacer()
            }
        }
    }
}
