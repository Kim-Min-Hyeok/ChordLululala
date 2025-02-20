//
//  DashBoardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashBoardViewModel()
    @State private var sidebarDragOffset: CGFloat = 0
    @State private var isFloatingMenuVisible: Bool = false
    private let sidebarWidth: CGFloat = 257
    
    // 리스트 모드 여부 (true: List, false: Grid)
    @State private var isListView: Bool = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                    .environmentObject(viewModel)
                    .padding(.top, 30)
                    .padding(.horizontal, 30)
                
                FileFolderFilterToggleView(selectedFilter: $viewModel.currentFilter)
                    .padding(.horizontal, 416)
                    .padding(.top, 33)
                
                HStack {
                    SortToggleView(selectedSort: $viewModel.selectedSort)
                    Spacer()
                    Button(action: {
                        // 선택 이미지 버튼 액션 (추후 구현)
                    }) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 21, height: 21)
                    }
                    .padding(.trailing, 8)
                    
                    // 리스트/그리드 토글 버튼
                    Button(action: {
                        isListView.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .frame(width: 21, height: 21)
                            .foregroundColor(isListView ? .blue : .gray)
                    }
                }
                .padding(.horizontal, 168)
                .padding(.top, 10)
                
                // 내부 콘텐츠 영역: 폴더와 파일 ContentView 분리하여 표시
                ScrollView {
                    VStack(alignment: .leading, spacing: CGFloat(isListView ? 0 : 80)) {
                        // 폴더 영역
                        if viewModel.currentFilter == .all || viewModel.currentFilter == .folder {
                            if isListView {
                                FolderListView(folders: viewModel.sortedFolders, cellSpacing: 18)
                            } else {
                                FolderGridView(folders: viewModel.sortedFolders, cellSpacing: 8)
                            }
                        }
                        // 파일 영역
                        if viewModel.currentFilter == .all || viewModel.currentFilter == .file {
                            if isListView {
                                FileListView(files: viewModel.sortedFiles, cellSpacing: 18)
                            } else {
                                FileGridView(files: viewModel.sortedFiles, cellSpacing: 8)
                            }
                        }
                    }
                    .padding(.horizontal, 168)
                }
                
                Spacer()
            }
            
            ZStack {
                // 메뉴가 열렸을 때 다른 영역 터치하면 닫히도록
                if isFloatingMenuVisible {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isFloatingMenuVisible = false
                            }
                        }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            Button(action: {
                                withAnimation {
                                    isFloatingMenuVisible.toggle()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 29)
                            .padding(.bottom, 40)
                            
                            // 메뉴 뷰: 플로팅 버튼 위에 (trailing: 29, bottom: 76)에 위치
                            if isFloatingMenuVisible {
                                VStack(spacing: 10) {
                                    FloatingMenuView(
                                        folderAction: {
                                            print("폴더 만들기 액션 실행")
                                            withAnimation {
                                                isFloatingMenuVisible.toggle()
                                            }
                                        },
                                        fileUploadAction: {
                                            print("파일 업로드 액션 실행")
                                            withAnimation {
                                                isFloatingMenuVisible.toggle()
                                            }
                                        }
                                    )
                                }
                                .padding(.trailing, 29)
                                .padding(.bottom, 76)
                                .transition(.opacity)
                            }
                        }
                    }
                }
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
            
            // 사이드바 (드래그 제스처 포함)
            HStack(spacing: 0) {
                SidebarView(onSelect: { newContent in
                    withAnimation(.easeInOut) {
                        viewModel.isSidebarVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
        .environmentObject(viewModel)
    }
}
