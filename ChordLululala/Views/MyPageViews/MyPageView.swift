//
//  MyPageView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/29/25.
//  Updated by GiYoung Kim on 4/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct BoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [Anchor<CGRect>] = []
    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

struct MyPageView: View {
    @EnvironmentObject var dashboardViewModel: DashBoardViewModel
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel = MyPageViewModel()
    
    @State private var shareURL: URL? = nil
    @State private var isSharePresented = false
    @State private var isImporterPresented = false
    
    @State private var isBackupPressed = false
    @State private var isTrashPressed = false
    @State private var isLanguageSettingPressed = false
    @State private var isLoadPressed = false
    @State private var isShowingLogoutModal = false
    @State private var isShowingDeleteAcountModal = false
    
    // MARK: 언어 변경 연결 전 토스트 기능 (한국어만 지원 시)
    @Binding var toastMessage: String
    @Binding var isShowingToast: Bool
    
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing : 0) {
                Spacer().frame(height: 95)
                
                // MARK: 유저 정보
                ProfileView(
                    name: viewModel.user?.name,
                    email: viewModel.user?.email,
                    profileImageURL: viewModel.user?.profileImageURL
                )
                
                // MARK: 백업하기 / 불러오기 버튼
                HStack(spacing: 10) {
                    BackupAndImportButton(
                        imageName: "load_button",
                        title: "불러오기",
                        action: { isImporterPresented = true }
                    )
                    BackupAndImportButton(
                        imageName: "share",
                        title: "내보내기",
                        action: { viewModel.backup() }
                    )
                }
                .padding(.bottom, 65)
                
                // MARK: 휴지통 / 언어설정 버튼
                VStack(spacing : 20){
                    MypageActionButton(
                        iconName: "trashcan_button",
                        title: "휴지통",
                        trailingView: {
                            HStack(spacing: 12) {
                                Text("\(viewModel.trashCount)개")
                                    .textStyle(.headingMdMedium)
                                    .foregroundColor(.primaryGray900)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.primaryGray900)
                                    .padding(.trailing, 18)
                            }
                        },
                        onTap: {
                            dashboardViewModel.dashboardContents = .trashCan
                        }
                    )
                    
                    MypageActionButton(
                        iconName: "language_setting_button",
                        title: "언어설정",
                        trailingView: {
                            HStack(spacing: 10) {
                                Text(viewModel.selectedLanguage.rawValue)
                                    .textStyle(.headingMdMedium)
                                    .foregroundColor(.primaryGray900)
                                Image("dropdown")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .padding(.trailing, 5)
                            }
                        },
                        onTap: {
                            isLanguageSettingPressed.toggle()
                        }
                    )
                    .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { [$0] }
                    //                    LanguageMenuView(myPageViewModel: viewModel)
                }
                
                Spacer()
                
                // MARK: 로그아웃 / 회원탈퇴 버튼
                HStack(spacing: 12) {
                    Button(action:{
                        isShowingLogoutModal = true
                    }) {
                        Text("로그아웃")
                            .font(.bodyTextXLRegular)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .foregroundColor(.primaryGray700)
                    }
                    .background(Color.primaryGray200)
                    .cornerRadius(5)
                    
                    Button(action:{
                        isShowingDeleteAcountModal = true;
                    }) {
                        Text("회원탈퇴")
                            .font(.bodyTextXLRegular)
                            .foregroundColor(.primaryGray400)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                    }
                    .background(Color.primaryGray100)
                    .cornerRadius(5)
                }
                .padding(.bottom, 21)
                
                // MARK: 약관 링크
                VStack(spacing: 4) {
                    Link(destination: URL(string: "https://inexpensive-witch-105.notion.site/Noteflow-22aee525885580d4aa8ace2a9bcf103a?source=copy_link")!) {
                        Text("개인정보 처리방침")
                            .textStyle(
                                TextStyle(
                                    font: .custom("Pretendard-Regular", size: 12),
                                    size: 12,
                                    lineHeightMultiplier: 1.4,
                                    letterSpacing: 24 * -0.0035
                                )
                            )
                            .foregroundColor(.primaryGray900)
                            .underline()
                    }
                    Link(destination: URL(string: "https://inexpensive-witch-105.notion.site/Noteflow-22aee525885580b8b88dca79c0cffab8?source=copy_link")!) {
                        Text("서비스 이용약관")
                            .textStyle(
                                TextStyle(
                                    font: .custom("Pretendard-Regular", size: 12),
                                    size: 12,
                                    lineHeightMultiplier: 1.4,
                                    letterSpacing: 24 * -0.0035
                                )
                            )
                            .foregroundColor(.primaryGray900)
                            .underline()
                    }
                }
                .padding(.bottom, 91)
            }
            .padding(.horizontal, 46)
            .background(Color.primaryGray50)
            .edgesIgnoringSafeArea(.bottom)
            
            // MARK: 언어설정 드롭다운
            .overlayPreferenceValue(BoundsPreferenceKey.self) { anchors in
                GeometryReader { geo in
                    if isLanguageSettingPressed, let anchor = anchors.first {
                        let rect = geo[anchor]
                        ZStack {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isLanguageSettingPressed = false
                                }
                            LanguageDropdownView(
                                selectedLanguage: $viewModel.selectedLanguage,
                                selectLanguage: { language in
                                    withAnimation {
                                        isLanguageSettingPressed = false
                                    }

                                    if language != .korean {
                                        toastMessage = "지금은 한국어만 사용 가능합니다."
                                        isShowingToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            isShowingToast = false
                                        }
                                    }

                                    viewModel.selectLanguage(language)
                                }
                            )
                            .padding(.horizontal, 46)
                            .position(x: rect.midX, y: rect.maxY + 61)
                        }
                    }
                }
            }
            
            // MARK: 모달들
            if isShowingLogoutModal {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowingLogoutModal = false
                        }
                    MyPageAccountModalView(
                        title: "로그아웃",
                        message: "로그아웃 하시겠어요?",
                        confirmTitle: "로그아웃",
                        cancelTitle: "취소",
                        onCancel: {
                            isShowingLogoutModal = false
                        },
                        onConfirm: {
                            viewModel.logout {
                                router.offAll("/login")
                            }
                        }
                    )
                }
            }
            
            if isShowingDeleteAcountModal {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowingDeleteAcountModal = false
                        }
                    MyPageAccountModalView(
                        title: "정말 탈퇴하시겠어요?",
                        message: "탈퇴 시 계정은 영구 삭제되어 복구할 수 없습니다.",
                        confirmTitle: "회원 탈퇴",
                        cancelTitle: "취소",
                        onCancel: {
                            isShowingDeleteAcountModal = false
                        },
                        onConfirm: {
                            viewModel.deleteAccount {
                                isShowingDeleteAcountModal = false
                                router.offAll("/login")
                            }
                        }
                    )
                }
            }
        }
        // MARK: 백업 완료 시 즉시 공유 시트 띄우기
        .onChange(of: viewModel.backupArchiveURL) { url in
            guard let url = url else { return }
            shareURL = url
            isSharePresented = true
            viewModel.backupArchiveURL = nil
        }
        // ② SwiftUI sheet 로 ActivityView 띄우기
        .sheet(isPresented: $isSharePresented, onDismiss: {
            shareURL = nil
        }) {
            if let url = shareURL {
                FileShareView(fileURL: url)
            }
        }
        // MARK: 불러오기 파일 임포터
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [UTType(filenameExtension: "aar")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let providerURL = urls.first {
                    viewModel.importBackupFile(from: providerURL)
                }
            case .failure(let error):
                viewModel.restoreError = error.localizedDescription
            }
        }
    }
}
