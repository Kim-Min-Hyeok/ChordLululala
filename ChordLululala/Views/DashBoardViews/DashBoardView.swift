//
//  DashBoardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashBoardViewModel()
    
    // MARK: 파일/폴더 생성 버튼 관련 상태
    @State private var isFloatingMenuVisible: Bool = false
    @State private var isShowingPDFPicker: Bool = false
    @State private var isShowingCreateFolderModal: Bool = false
    
    // MARK: 사이드바 관련 설정
    @State private var sidebarDragOffset: CGFloat = 0
    private let sidebarWidth: CGFloat = 257
    
    // MARK: 수정 모달 상태
    @State private var showModifyModal = false
    @State private var selectedContent: Content? = nil
    @State private var modalFrame: CGRect = .zero
    
    // MARK: 리스트/그리드 상태
    @State private var isListView: Bool = true
    
    var body: some View {
        // MARK: 파일 생성 시트 (파일 Picker) & 폴더 생성 모달 구현을 위한 ZStack
        ZStack {
            // MARK: 사이드바 & 파일/폴더 생성/수정 메뉴 구현을 위한 ZStack
            ZStack {
                VStack(spacing: 0) {
                    // TODO: 테스트용 이전 폴더 되돌아가기
                    if viewModel.currentParent != nil {
                        HStack {
                            Button(action: {
                                viewModel.goBack()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("상위 폴더")
                                }
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    
                    // MARK: HEADER
                    HeaderView()
                        .environmentObject(viewModel)
                        .padding(.top, 30)
                        .padding(.horizontal, 30)
                    
                    // MARK: 전체/파일/폴더
                    FileFolderFilterToggleView(selectedFilter: $viewModel.currentFilter)
                        .padding(.horizontal, 416)
                        .padding(.top, 33)
                    
                    HStack {
                        // MARK: 날짜순/이름순
                        SortToggleView(selectedSort: $viewModel.selectedSort)
                        Spacer()
                        
                        // MARK: 선택 버튼
                        Button(action: {
                            // TODO: 선택 이미지 버튼 액션 (추후 구현)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .frame(width: 21, height: 21)
                        }
                        .padding(.trailing, 8)
                        
                        // MARK: 리스트/그리드 토글 버튼
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
                    
                    // TODO: 테스트용: 모든 데이터 삭제 버튼
                    Button("모든 데이터 삭제") {
                        ContentManager.shared.deleteAllCoreDataObjects()
                        FileManagerManager.shared.deleteAllFilesInScoreFolder()
                    }
                    .padding(.vertical, 50)
                    
                    // MARK: 파일/폴더 리스트/그리드 뷰
                    ScrollView {
                        ContentListView(isListView: isListView,
                                        onFolderTap: { folder in
                            viewModel.didTapFolder(folder)
                        },
                                        onFolderEllipsisTapped: { folder, frame in
                            selectedContent = folder
                            modalFrame = frame
                            showModifyModal = true
                        },
                                        onFileTap: { file in
                        },
                                        onFileEllipsisTapped: { file, frame in
                            selectedContent = file
                            modalFrame = frame
                            showModifyModal = true
                        }
                        )
                    }
                    Spacer()
                }
                
                // MARK: 수정 모달 뷰
                if showModifyModal, let content = selectedContent {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showModifyModal = false
                        }
                    
                    // 셀 별 모달 뷰 위치 설정
                    let modalHeight: CGFloat = 195
                    let screenHeight = UIScreen.main.bounds.height
                    let desiredY: CGFloat = (modalFrame.maxY + modalHeight > screenHeight)
                    ? (modalFrame.minY - 30 - modalHeight/2)
                    : (modalFrame.maxY - 20 + modalHeight/2)
                    
                    ModifyModalView(content: content,
                                    onDismiss: { showModifyModal = false },
                                    onRename: { newName in
                        viewModel.renameContent(content, newName: newName)
                    },
                                    onDuplicate: {
                        viewModel.duplicateContent(content)
                    },
                                    onMoveToTrash: {
                        viewModel.moveContentToTrash(content)
                    }
                    )
                    .frame(width: 273, height: modalHeight)
                    .position(
                        x: modalFrame.maxX - 273/2, // 모달 width가 250이므로, 오른쪽 정렬
                        y: desiredY
                    )
                    .transition(.opacity)
                }
                
                // MARK: 파일 생성 모달 뷰
                ZStack {
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
                                
                                if isFloatingMenuVisible {
                                    VStack(spacing: 10) {
                                        FloatingMenuView(
                                            folderAction: {
                                                withAnimation {
                                                    isFloatingMenuVisible.toggle()
                                                    isShowingCreateFolderModal = true
                                                }
                                            },
                                            fileUploadAction: {
                                                withAnimation {
                                                    isFloatingMenuVisible.toggle()
                                                    isShowingPDFPicker = true
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
                
                // MARK: 사이드바 오버레이 배경
                if viewModel.isSidebarVisible {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                viewModel.isSidebarVisible = false
                            }
                        }
                }
                
                // MARK: 사이드바
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
            
            // MARK: 파일 생성 시트 (파일 Picker)
            .sheet(isPresented: $isShowingPDFPicker) {
                PDFPicker { selectedURL in
                    viewModel.uploadFile(with: selectedURL)
                    isShowingPDFPicker = false
                }
            }
            
            // MARK: 폴더 생성 모달
            if isShowingCreateFolderModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowingCreateFolderModal = false
                    }
                CreateFolderModalView(currentParent: viewModel.currentParent) { folderName, _ in
                    viewModel.createFolder(folderName: folderName)
                    isShowingCreateFolderModal = false
                }
                .transition(.opacity)
            }
        }
    }
}
