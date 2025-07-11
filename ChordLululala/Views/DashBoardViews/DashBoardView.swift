//
//  DashBoardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashBoardViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        // MARK: 휴지통 이동 모달 구현을 위한 ZStack
        ZStack {
            // MARK: 파일 생성 시트 (파일 Picker) & 폴더 생성 모달 구현을 위한 ZStack
            ZStack {
                // MARK: 전체 / 사이드바
                HStack(spacing: 0) {
                    // MARK: 사이드바
                    if viewModel.isLandscape && !viewModel.isSelectionViewVisible && !viewModel.isSearching && viewModel.dashboardContents != .createSetlist {
                        SidebarView(
                            onSelect: { newContent in
                                viewModel.dashboardContents = newContent
                            },
                            selected: $viewModel.dashboardContents
                        )
                    }
                    // MARK: 전체 / 탭바
                    VStack {
                        // MARK: 마이페이지
                        if viewModel.dashboardContents == .myPage {
                            MyPageView(
                                toastMessage: $toastMessage,
                                isShowingToast: $showToast
                            )
                        }
                        else if viewModel.dashboardContents == .createSetlist {
                            CreateSetlistView()
                        }
                        else {
                            // MARK: 파일/폴더 생성/수정 메뉴 구현을 위한 ZStack
                            ZStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    if !viewModel.isSelectionViewVisible {
                                        // MARK: HEADER
                                        DashBoardHeaderView()
                                            .environmentObject(viewModel)
                                            .padding(.top, 33)
                                    }
                                    else {
                                        Rectangle()
                                            .frame(height: 151)
                                    }
                                    // MARK: 파일/폴더 리스트/그리드 뷰
                                    ScrollView {
                                        ContentListView(isListView: viewModel.isListView)
                                    }
                                    .padding(.top, viewModel.isSelectionViewVisible ? (viewModel.isLandscape ? 50 : 94) : (viewModel.isLandscape ? 29 : 72))
                                    Spacer()
                                }
                                .padding(.horizontal, viewModel.isSelectionViewVisible ? (viewModel.isLandscape ? 167 : 45) : 44)
                                
                                if viewModel.dashboardContents != .trashCan && !viewModel.isSelectionViewVisible && !viewModel.isSearching {
                                    // MARK: 파일 생성 모달 뷰
                                    ZStack {
                                        if viewModel.isFloatingMenuVisible {
                                            Color.clear
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    withAnimation {
                                                        viewModel.isFloatingMenuVisible = false
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
                                                            viewModel.isFloatingMenuVisible.toggle()
                                                        }
                                                    }) {
                                                        Image("plus")
                                                            .resizable()
                                                            .frame(width: 18, height: 18)
                                                            .padding(18)
                                                            .background(Color.primaryGray800)
                                                            .clipShape(Circle())
                                                    }
                                                    .shadow(color: Color.black.opacity(0.40), radius: 30, x: 0, y: 0)
                                                    .padding(.trailing, 41)
                                                    .padding(.bottom, viewModel.isLandscape ? 7 : 25)
                                                    
                                                    if viewModel.isFloatingMenuVisible {
                                                        VStack(spacing: 10) {
                                                            FloatingMenuView(
                                                            )
                                                        }
                                                        .padding(.trailing, 41)
                                                        .padding(.bottom, viewModel.isLandscape ? 75 : 93)
                                                        .transition(.opacity)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !viewModel.isLandscape && !viewModel.isSelectionViewVisible && !viewModel.isSearching {
                            TabBarView(
                                onSelect: { newContent in
                                    viewModel.dashboardContents = newContent
                                },
                                selected: $viewModel.dashboardContents
                            )
                        }
                    }
                    
                }
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        self.hideKeyboard()
                    }
                )
                
                // MARK: 파일 생성 시트 (앨범 Picker)
                .sheet(isPresented: $viewModel.isAlbumPickerVisible) {
                    PhotoPicker { pickedURL in
                        viewModel.uploadFile(with: pickedURL)
                        viewModel.isAlbumPickerVisible = false
                    }
                }
                
                // MARK: 파일 생성 시트 (파일 Picker)
                .sheet(isPresented: $viewModel.isPDFPickerVisible) {
                    FilePicker { selectedURL in
                        viewModel.uploadFile(with: selectedURL)
                        viewModel.isPDFPickerVisible = false
                    }
                }
                // MARK: 셋리스트 생성 모달
                if viewModel.isCreateSetlistModalVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.isCreateSetlistModalVisible = false
                        }
                    
                    SetContentNameModalView(
                        "셋리스트 생성",
                        "생성할 셋리스트의 이름을 작성해주세요.",
                        ""
                    ) { setlistName in
                        viewModel.nameOfSetlistCreating = setlistName
                        viewModel.isCreateSetlistModalVisible = false
                        viewModel.dashboardContents = .createSetlist
                    } onCancel: {
                        viewModel.isCreateSetlistModalVisible = false
                    }
                }
                // MARK: 폴더 생성 모달
                if viewModel.isCreateFolderModalVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.isCreateFolderModalVisible = false
                        }
                    
                    SetContentNameModalView(
                        "폴더 생성",
                        "생성할 폴더의 이름을 작성해주세요.",
                        ""
                    ) { folderName in
                        viewModel.createFolder(folderName: folderName)
                        viewModel.isCreateFolderModalVisible = false
                    } onCancel: {
                        viewModel.isCreateFolderModalVisible = false
                    }
                }
                // MARK: Content 이름 수정 모달
                if viewModel.isRenameModalVisible, let content = viewModel.selectedContent {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.isRenameModalVisible = false
                        }
                    let (titleText, bodyText): (String, String) = {
                        switch ContentType(rawValue: content.type) {
                        case .folder:
                            return ("폴더 이름 변경", "이 폴더의 새로운 이름을 입력하십시오.")
                        case .score, .scoresOfSetlist:
                            return ("파일 이름 변경", "이 파일의 새로운 이름을 입력하십시오.")
                        case .setlist:
                            return ("셋리스트 이름 변경", "이 셋리스트의 새로운 이름을 입력하십시오.")
                        default:
                            return ("이름 변경", "새로운 이름을 입력하십시오.")
                        }
                    }()
                    
                    let baseName = ((content.name ?? "") as NSString).deletingPathExtension
                    
                    SetContentNameModalView(
                        titleText,
                        bodyText,
                        baseName  // ← 여기서 미리 가공해서 넘김
                    ) { newName in
                        // 확장자 붙이기 (필요하면)
                        let ext = ((content.name ?? "") as NSString).pathExtension
                        let finalName = ext.isEmpty ? newName : "\(newName).\(ext)"
                        viewModel.renameContent(content, newName: finalName)
                        viewModel.isRenameModalVisible = false
                    } onCancel: {
                        viewModel.isRenameModalVisible = false
                    }
                }
            }
            // MARK: 선택 모드 뷰
            .overlay(
                Group {
                    if viewModel.isSelectionViewVisible {
                        SelectionView(onMove: handleMoveAction)
                    }
                },
                alignment: .top
            )
            
            .overlay(
                Group {
                    if showToast {
                        ToastView(message: toastMessage)
                            .frame(width: 324, height: 54)
                            .padding(.leading, 25)
                            .padding(.bottom, 7)
                    }
                },
                alignment: .bottomLeading
            )
            
            // MARK: 휴지통 이동 모달
            if viewModel.isTrashModalVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isTrashModalVisible = false
                    }
                TrashModalView()
                    .transition(.opacity)
            }
            
            // MARK: 파일 이동 모달
            if viewModel.isMoveModalVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isMoveModalVisible = false
                        viewModel.selectedDestination = nil
                    }
                MoveModalView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)) { _ in
                let screen = UIScreen.main.bounds
                withAnimation {
                    viewModel.isLandscape = screen.width > screen.height
                }
            }
            .background(Color.primaryGray50)
            .environmentObject(viewModel)
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.importFromDropboxAndLoadContents()
            }
    }
    
    private func handleMoveAction() {
        let hadFolders = viewModel.selectedContents.contains { $0.type == ContentType.folder.rawValue }
        if hadFolders {
            toastMessage = "폴더는 이동할 수 없습니다. 제외해주세요."
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        } else if !viewModel.selectedContents.isEmpty {
            viewModel.isMoveModalVisible = true
        }
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .textStyle(.bodyTextLgMedium)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .background(Color(hex: "111827").opacity(0.9))
            .foregroundColor(Color.primaryGray50)
            .cornerRadius(7)
    }
}
