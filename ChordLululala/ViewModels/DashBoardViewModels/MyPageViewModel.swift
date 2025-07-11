//
//  MyPageViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/29/25.
//

import SwiftUI
import Combine

enum AvailableLanguages: String, CaseIterable {
    case korean = "한국어"
    case english = "영어"
}

enum BackupState {
    case idle, backingUp, restoring
}

class MyPageViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var trashCount: Int = 0
    @Published var selectedLanguage: AvailableLanguages = .korean
    
    @Published var backupArchiveURL: URL?
    @Published var backupError: String?
    @Published var restoreError: String?
    
    @Published var backupState: BackupState = .idle
    @Published var progressValue: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.user = UserManager.shared.currentUser
        bindUserUpdates()
        loadTrashCount()
    }
    
    private func bindUserUpdates() {
        UserManager.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
            }
            .store(in: &cancellables)
    }
    
    func loadTrashCount() {
        ContentManager.shared
            .loadContents(forParent: nil, dashboardContents: .trashCan)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ Failed to load trash contents: \(error)")
                    }
                },
                receiveValue: { [weak self] contents in
                    self?.trashCount = contents.count
                    print("🗑️ Trash count: \(contents.count)")
                }
            )
            .store(in: &cancellables)
    }
    
    func selectLanguage(_ language: AvailableLanguages) {
        // TODO: 언어 변경 연결
        //        selectedLanguage = language
        DispatchQueue.main.async {
            self.selectedLanguage = .korean
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        UserManager.shared.logout()
        completion()
    }
    
    func deleteAccount(completion: @escaping () -> Void) {
        CoreDataManager.shared.deleteAllCoreDataObjects()
        FileManagerManager.shared.deleteAllFilesInDocumentsFolder()
        UserManager.shared.logout()
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    /// 백업 생성
    func backup() {
            DispatchQueue.main.async {
                self.backupState   = .backingUp
                self.progressValue = 0
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let url = try BackupManager.shared.createBackup { prog in
                        // prog 값은 0.0, 0.33, 0.66, 0.90, 1.0 등으로 전달된다고 가정
                        DispatchQueue.main.async {
                            self.progressValue = prog
                        }
                    }
                    DispatchQueue.main.async {
                        self.backupArchiveURL = url
                        self.backupError      = nil
                        self.backupState      = .idle
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.backupError      = error.localizedDescription
                        self.progressValue    = 0
                        self.backupState      = .idle
                    }
                }
            }
        }

        /// 일반 복원 (단계별 진행 반영)
        func restore(from archiveURL: URL) {
            DispatchQueue.main.async {
                self.backupState   = .restoring
                self.progressValue = 0
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try BackupManager.shared.restoreBackup(from: archiveURL) { prog in
                        DispatchQueue.main.async {
                            self.progressValue = prog
                        }
                    }
                    DispatchQueue.main.async {
                        self.restoreError = nil
                        self.backupState  = .idle
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.restoreError    = error.localizedDescription
                        self.progressValue   = 0
                        self.backupState     = .idle
                    }
                }
            }
        }

        /// 파일 제공자 URL로부터 복원 (역시 단계별 진행 반영)
        func importBackupFile(from providerURL: URL) {
            DispatchQueue.main.async {
                self.backupState   = .restoring
                self.progressValue = 0
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let accessed = providerURL.startAccessingSecurityScopedResource()
                defer { if accessed { providerURL.stopAccessingSecurityScopedResource() } }

                let tmp = FileManager.default.temporaryDirectory
                    .appendingPathComponent(providerURL.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: tmp.path) {
                        try FileManager.default.removeItem(at: tmp)
                    }
                    try FileManager.default.copyItem(at: providerURL, to: tmp)

                    try BackupManager.shared.restoreBackup(from: tmp) { prog in
                        DispatchQueue.main.async {
                            self.progressValue = prog
                        }
                    }
                    DispatchQueue.main.async {
                        self.restoreError = nil
                        self.backupState  = .idle
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.restoreError    = error.localizedDescription
                        self.progressValue   = 0
                        self.backupState     = .idle
                    }
                }
            }
        }
}
