//
//  DashBoardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashBoardViewModel()
    
    var body: some View {
        // MARK: 휴지통 이동 모달 구현을 위한 ZStack
        ZStack {
            // MARK: 파일 생성 시트 (파일 Picker) & 폴더 생성 모달 구현을 위한 ZStack
            ZStack {
                // MARK: 전체 / 사이드바
                HStack(spacing: 0) {
                    // MARK: 사이드바
                    if viewModel.isLandscape && !viewModel.isSelectionViewVisible {
                        SidebarView(onSelect: { newContent in
                            viewModel.dashboardContents = newContent
                        })
                    }
                    // MARK: 전체 / 탭바
                    VStack {
                        // MARK: 마이페이지
                        if viewModel.dashboardContents == .myPage {
                            MyPageView()
                        }
                        else {
                            // MARK: 파일/폴더 생성/수정 메뉴 구현을 위한 ZStack
                            ZStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    if !viewModel.isSelectionViewVisible {
                                        // MARK: HEADER
                                        HeaderView()
                                            .environmentObject(viewModel)
                                            .padding(.top, 33)
                                        
                                        // TODO: 테스트용: 모든 데이터 삭제 버튼
                                        //                                    Button("모든 데이터 삭제") {
                                        //                                        CoreDataManager.shared.deleteAllCoreDataObjects()
                                        //                                        FileManagerManager.shared.deleteAllFilesInDocumentsFolder()
                                        //                                    }
                                        //                                    .padding(.vertical, 50)
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
                                
                                if viewModel.dashboardContents != .trashCan && !viewModel.isSelectionViewVisible {
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
                        
                        if !viewModel.isLandscape && !viewModel.isSelectionViewVisible {
                            TabBarView(onSelect: { newContent in
                                viewModel.dashboardContents = newContent
                            })
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
                
                // MARK: 폴더 생성 모달
                if viewModel.isCreateFolderModalVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.isCreateFolderModalVisible = false
                        }
                    CreateFolderModalView(isPresented: $viewModel.isCreateFolderModalVisible,
                                          currentParent: viewModel.currentParent) { folderName, _ in
                        print("parent: \(String(describing: viewModel.currentParent)), dashboardContent: \(viewModel.dashboardContents)")
                        viewModel.createFolder(folderName: folderName)
                        print("parent: \(String(describing: viewModel.currentParent)), dashboardContent: \(viewModel.dashboardContents)")
                    }
                                          .transition(.opacity)
                }
                if viewModel.isRenameModalVisible, let content = viewModel.selectedContent {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.isRenameModalVisible = false
                        }
                    RenameModalView(content: content)
                }
            }
            // MARK: 선택 모드 뷰
            .overlay(
                Group {
                    if viewModel.isSelectionViewVisible {
                        SelectionView()
                    }
                },
                alignment: .top
            )
            
            // MARK: 휴지통 이동 모달
            if viewModel.isTrashModalVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isTrashModalVisible = false
                        viewModel.isSelectionViewVisible = false
                    }
                TrashModalView()
                    .transition(.opacity)
            }
        }
        // 방향 감지
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
    }
}
