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

class MyPageViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var trashCount: Int = 0
    @Published var selectedLanguage: AvailableLanguages = .korean
    
    @Published var backupArchiveURL: URL?
    @Published var backupError: String?
    @Published var restoreError: String?
    @Published var isBusy = false
    
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
        selectedLanguage = language
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
    
    /// 백업
    func backup() {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let url = try BackupManager.shared.createBackup()
                DispatchQueue.main.async {
                    self.backupArchiveURL = url
                    self.backupError = nil
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.backupError = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
    }
    
    /// 복원
    func restore(from archiveURL: URL) {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try BackupManager.shared.restoreBackup(from: archiveURL)
                DispatchQueue.main.async {
                    self.restoreError = nil
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.restoreError = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
    }
    
    func importBackupFile(from providerURL: URL) {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async {
            // 1) security scope 접근
            let accessed = providerURL.startAccessingSecurityScopedResource()
            defer { if accessed { providerURL.stopAccessingSecurityScopedResource() } }
            
            // 2) 임시 디렉토리로 복사
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(providerURL.lastPathComponent)
            do {
                if FileManager.default.fileExists(atPath: tmpURL.path) {
                    try FileManager.default.removeItem(at: tmpURL)
                }
                try FileManager.default.copyItem(at: providerURL, to: tmpURL)
                
                // 3) 실제 복원 로직 호출
                try BackupManager.shared.restoreBackup(from: tmpURL)
                
                DispatchQueue.main.async {
                    self.restoreError = nil
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.restoreError = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
    }
}
