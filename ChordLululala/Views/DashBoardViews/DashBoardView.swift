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
                // MARK: 파일/폴더 생성/수정 메뉴 구현을 위한 ZStack
                ZStack {
                    HStack(spacing: 0) {
                        // MARK: 사이드바
                        SidebarView(onSelect: { newContent in
                            
                            viewModel.dashboardContents = newContent
                        })
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // TODO: 테스트용 이전 폴더 되돌아가기
                            if !viewModel.isSelectionViewVisible {
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
                                    .padding(.top, 33)
                                
                                
                                
                                    // MARK: 최신순/이름순
                                    SortToggleView(selectedSort: $viewModel.selectedSort)
                                .padding(.top, 29)
                                
                                // TODO: 테스트용: 모든 데이터 삭제 버튼
                                Button("모든 데이터 삭제") {
                                    CoreDataManager.shared.deleteAllCoreDataObjects()
                                    FileManagerManager.shared.deleteAllFilesInDocumentsFolder()
                                }
                                .padding(.vertical, 50)
                            }
                            else {
                                Rectangle()
                                    .frame(height: 168)
                            }
                            
                            // MARK: 파일/폴더 리스트/그리드 뷰
                            ScrollView {
                                ContentListView(isListView: viewModel.isListView)
                            }
                            .padding(.top, 70)
                            Spacer()
                        }
                        .padding(.horizontal, 44)
                    }
                    
                    // MARK: 수정 모달 뷰
                    // TODO: 디자인 시스템 입혀야함
                    if viewModel.isModifyModalVisible, let content = viewModel.selectedContent {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                viewModel.isModifyModalVisible = false
                            }
                        
                        // 셀 별 모달 뷰 위치 설정
                        let modalHeight: CGFloat = 195
                        let screenHeight = UIScreen.main.bounds.height
                        let desiredY: CGFloat = (viewModel.cellFrame.maxY + modalHeight > screenHeight)
                        ? (viewModel.cellFrame.minY - 30 - modalHeight/2)
                        : (viewModel.cellFrame.maxY - 20 + modalHeight/2)
                        
                        ModifyModalView(content: content)
                            .frame(width: 273, height: modalHeight)
                            .position(
                                x: viewModel.cellFrame.maxX - 273/2, // 모달 width가 250이므로, 오른쪽 정렬
                                y: desiredY
                            )
                            .transition(.opacity)
                    }
                    
                    if viewModel.isDeletedModalVisible, let content = viewModel.selectedContent {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                viewModel.isDeletedModalVisible = false
                            }
                        
                        // 셀 별 모달 뷰 위치 설정
                        let modalHeight: CGFloat = 195
                        let screenHeight = UIScreen.main.bounds.height
                        let desiredY: CGFloat = (viewModel.cellFrame.maxY + modalHeight > screenHeight)
                        ? (viewModel.cellFrame.minY - 30 - modalHeight/2)
                        : (viewModel.cellFrame.maxY - 20 + modalHeight/2)
                        
                        DeleteModalView(content: content)
                            .frame(width: 273, height: modalHeight)
                            .position(
                                x: viewModel.cellFrame.maxX - 273/2, // 모달 width가 250이므로, 오른쪽 정렬
                                y: desiredY
                            )
                            .transition(.opacity)
                    }
                    
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
                                    if viewModel.dashboardContents != .trashCan {
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
                                        .padding(.bottom, 7)
                                    }
                                    
                                    if viewModel.isFloatingMenuVisible {
                                        VStack(spacing: 10) {
                                            FloatingMenuView(
                                                folderAction: {
                                                    withAnimation {
                                                        viewModel.isFloatingMenuVisible.toggle()
                                                        viewModel.isCreateFolderModalVisible = true
                                                    }
                                                },
                                                fileUploadAction: {
                                                    withAnimation {
                                                        viewModel.isFloatingMenuVisible.toggle()
                                                        viewModel.isPDFPickerVisible = true
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
                }
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        self.hideKeyboard()
                    }
                )
                
                // MARK: 파일 생성 시트 (파일 Picker)
                .sheet(isPresented: $viewModel.isPDFPickerVisible) {
                    FilePicker { selectedURL in
                        viewModel.uploadFile(with: selectedURL)
                        viewModel.isPDFPickerVisible = false
                    }
                }
                
                // MARK: 폴더 생성 모달
                if viewModel.isCreateFolderModalVisible {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.isCreateFolderModalVisible = false
                        }
                    CreateFolderModalView(isPresented: $viewModel.isCreateFolderModalVisible,
                                          currentParent: viewModel.currentParent) { folderName, _ in
                        print("parent: \(String(describing: viewModel.currentParent)), dashboardContent: \(viewModel.dashboardContents)")
                        viewModel.createFolder(folderName: folderName)
                        // 여기서는 모달이 자동으로 바인딩에 의해 닫힙니다.
                        print("parent: \(String(describing: viewModel.currentParent)), dashboardContent: \(viewModel.dashboardContents)")
                    }
                    .transition(.opacity)
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
        .environmentObject(viewModel)
        .navigationBarHidden(true)
    }
}
