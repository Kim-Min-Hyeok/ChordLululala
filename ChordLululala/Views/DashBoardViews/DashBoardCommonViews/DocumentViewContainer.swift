//
//  DocumentViewContainer.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DocumentViewContainer<Content: View>: View {
    @StateObject private var viewModel = DocumentViewModel()
    @State private var sidebarDragOffset: CGFloat = 0
    private let sidebarWidth: CGFloat = 257
    
    @State private var currentFilter: ToggleFilter = .all
        
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 메인 콘텐츠 영역: Header + 사용자 콘텐츠
            VStack(spacing: 0) {
                HeaderView()
                    .environmentObject(viewModel)
                    .padding(.top, 30)
                    .padding(.horizontal, 30)
                FileFolderFilterToggleView(selectedFilter: $currentFilter)
                                    .padding(.horizontal, 416)
                                    .padding(.top, 33)
                content
                Spacer()
            }
            
            if viewModel.isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            viewModel.isSidebarVisible = false
                        }
                    }
            }
            
            // 사이드바 (버튼+드래그로 열고 닫기)
            HStack(spacing: 0) {
                SidebarView()
                    .environmentObject(viewModel)
                    .frame(width: sidebarWidth)                    .offset(x: (viewModel.isSidebarVisible ? 0 : -sidebarWidth) + sidebarDragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                sidebarDragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold = sidebarWidth / 2
                                if viewModel.isSidebarVisible {
                                    // 열려 있을 때 왼쪽으로 드래그하면 닫기
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
