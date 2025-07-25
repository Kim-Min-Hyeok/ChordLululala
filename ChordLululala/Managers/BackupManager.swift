// BackupManager.swift
// ChordLululala
//
// Created by Minhyeok Kim on 6/14/25.
// Updated by You on 6/14/25.

// BackupManager.swift

import Foundation

enum BackupError: Error {
    case missingDocuments
}

final class BackupManager {
    static let shared = BackupManager()
    private let fm = FileManager.default

    func createBackup(archiveName: String = "NoteFlow_Backup.aar",
                      progress: @escaping (Double) -> Void) throws -> URL {
        progress(0)

        // 🔥 백업 전 필수 작업: 무결성 체크 및 자동정리 추가
        CoreDataManager.shared.validateRelationshipsBeforeBackup()
        CoreDataManager.shared.cleanBrokenContentRelationships()

        // CoreData ID 백필
        try CoreDataManager.shared.backfillAllEntityIDs()
        progress(0.2)

        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.missingDocuments
        }

        let tmpRoot = fm.temporaryDirectory.appendingPathComponent("NoteFlow_Backup", isDirectory: true)
        try? fm.removeItem(at: tmpRoot)
        try fm.createDirectory(at: tmpRoot, withIntermediateDirectories: true)
        progress(0.4)

        let coreDir = tmpRoot.appendingPathComponent("CoreData", isDirectory: true)
        try CoreDataManager.shared.backupStoreFiles(to: coreDir)
        progress(0.5)

        for name in ["Score"] {
            let src = docs.appendingPathComponent(name, isDirectory: true)
            let dst = tmpRoot.appendingPathComponent(name, isDirectory: true)
            if fm.fileExists(atPath: src.path) {
                try fm.copyItem(at: src, to: dst)
            }
        }
        progress(0.6)

        let plainURL = docs.appendingPathComponent(archiveName)
        if fm.fileExists(atPath: plainURL.path) {
            try fm.removeItem(at: plainURL)
        }
        try FileManagerManager.shared.compressDirectory(tmpRoot, toArchive: plainURL)
        progress(0.8)

        try EncryptionManager.shared.encryptFile(at: plainURL, to: plainURL)
        progress(1.0)

        try? fm.removeItem(at: tmpRoot)
        return plainURL
    }


        /// 백업 복원 (단계별 프로그레스 제공)
    func restoreBackup(from archiveURL: URL,
                       progress: @escaping (Double) -> Void) throws {
        progress(0)

        // 1) 복호화된 .aar 파일 준비
        let decryptedURL = fm.temporaryDirectory
            .appendingPathComponent("Decrypted_Backup.aar")
        try? fm.removeItem(at: decryptedURL)
        try EncryptionManager.shared.decryptFile(at: archiveURL, to: decryptedURL)
        progress(0.3)

        // 2) 압축 해제
        let tmp = fm.temporaryDirectory
            .appendingPathComponent("NoteFlow_Backup", isDirectory: true)
        try? fm.removeItem(at: tmp)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        try FileManagerManager.shared.decompressArchive(decryptedURL, to: tmp)
        progress(0.5)

        // 3) CoreData 병합
        let sqliteURL = tmp.appendingPathComponent("CoreData/ChordLululala.sqlite")
        try CoreDataManager.shared.mergeBackupStore(at: sqliteURL)
        try CoreDataManager.shared.saveContext() // 🔥 여기서 명확히 저장
        progress(0.8)

        // 4) 파일 복사 (완전 복구된 데이터를 기반으로!)
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.missingDocuments
        }
        
        let allContents = ContentCoreDataManager.shared.fetchContentsSync()
        for content in allContents {
            guard let rel = content.path, !rel.isEmpty else { continue }
            let src = tmp.appendingPathComponent(rel)
            let dst = docs.appendingPathComponent(rel)
            let folder = (rel as NSString).deletingLastPathComponent
            if !folder.isEmpty {
                _ = FileManagerManager.shared.createSubfolderIfNeeded(for: folder)
            }
            if fm.fileExists(atPath: src.path) && !fm.fileExists(atPath: dst.path) {
                try fm.copyItem(at: src, to: dst)
            }
        }
        progress(1.0)

        // 5) 임시 정리
        try? fm.removeItem(at: tmp)
        try? fm.removeItem(at: decryptedURL)
    }

    }
