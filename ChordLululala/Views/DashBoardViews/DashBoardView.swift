//
//  DashBoardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashBoardViewModel() // 새 뷰모델 사용
    @State private var sidebarDragOffset: CGFloat = 0
    private let sidebarWidth: CGFloat = 257
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                    .environmentObject(viewModel)
                    .padding(.top, 30)
                    .padding(.horizontal, 30)
                // 파일/폴더 토글 (바인딩을 뷰모델로)
                FileFolderFilterToggleView(selectedFilter: $viewModel.currentFilter)
                    .padding(.horizontal, 416)
                    .padding(.top, 33)
                
                HStack {
                    SortToggleView(selectedSort: $viewModel.selectedSort)
                        .frame(maxWidth: 150)
                    Spacer()
                    Button(action: {
                    }) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 21, height: 21)
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: {
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .frame(width: 21, height: 21)
                    }
                }
                .padding(.horizontal, 168)
                .padding(.top, 10)
                
                Group {
                    switch viewModel.selectedContent {
                    case .allDocuments:
                        AllDocumentContentView()
                    case .recentDocuments:
                        RecentDocumentContentView()
                    case .songList:
                        SongListContentView()
                    case .trashCan:
                        TrashCanContentView()
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            
            // 사이드바 오버레이 배경
            if viewModel.isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            viewModel.isSidebarVisible = false
                        }
                    }
            }
            
            HStack(spacing: 0) {
                SidebarView(onSelect: { newContent in
                    withAnimation(.easeInOut) {
                        viewModel.isSidebarVisible = false
                        viewModel.selectedContent = newContent
                    }
                })
                .environmentObject(viewModel)
                .frame(width: sidebarWidth)
                .offset(x: (viewModel.isSidebarVisible ? 0 : -sidebarWidth) + sidebarDragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            sidebarDragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = sidebarWidth / 2
                            if viewModel.isSidebarVisible {
                                if value.translation.width < -threshold {
                                    withAnimation(.easeInOut) {
                                        viewModel.isSidebarVisible = false
                                    }
                                }
                            } else {
                                if value.translation.width > threshold {
                                    withAnimation(.easeInOut) {
                                        viewModel.isSidebarVisible = true
                                    }
                                }
                            }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sidebarDragOffset = 0
                            }
                        }
                )
                Spacer()
            }
            .ignoresSafeArea(edges: .leading)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                self.hideKeyboard()
            }
        )
    }
}
