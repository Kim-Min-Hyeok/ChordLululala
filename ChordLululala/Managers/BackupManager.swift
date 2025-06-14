// BackupManager.swift
// ChordLululala
//
// Created by Minhyeok Kim on 6/14/25.
// Updated by You on 6/14/25.

import Foundation

enum BackupError: Error {
    case missingDocuments
}

final class BackupManager {
    static let shared = BackupManager()
    private let fm = FileManager.default
    
    /// 전체 백업(.aar) 생성
    func createBackup(archiveName: String = "NoteFlow_Backup.aar") throws -> URL {
        try CoreDataManager.shared.backfillAllEntityIDs()
        
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw BackupError.missingDocuments }
        
        // 1) 임시 백업 루트
        let tmpRoot = fm.temporaryDirectory
            .appendingPathComponent("NoteFlow_Backup", isDirectory: true)
        try? fm.removeItem(at: tmpRoot)
        try fm.createDirectory(at: tmpRoot, withIntermediateDirectories: true)
        
        // 2) CoreData 스토어 파일 복사 (JSON 대신)
        let coreDir = tmpRoot.appendingPathComponent("CoreData", isDirectory: true)
        try CoreDataManager.shared.backupStoreFiles(to: coreDir)
        
        // 3) Score/TrashCan 전체 복사
        for name in ["Score","TrashCan"] {
            let src = docs.appendingPathComponent(name, isDirectory: true)
            let dst = tmpRoot.appendingPathComponent(name, isDirectory: true)
            if fm.fileExists(atPath: src.path) {
                try fm.copyItem(at: src, to: dst)
            }
        }
        
        // 4) 압축
        let archiveURL = docs.appendingPathComponent(archiveName)
        if fm.fileExists(atPath: archiveURL.path) {
            try fm.removeItem(at: archiveURL)
        }
        try FileManagerManager.shared.compressDirectory(tmpRoot, toArchive: archiveURL)
        try EncryptionManager.shared.encryptFile(at: archiveURL, to: archiveURL)
        
        return archiveURL
    }
    
    /// 백업 복원
    func restoreBackup(from archiveURL: URL) throws {
        try CoreDataManager.shared.backfillAllEntityIDs()
        
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.missingDocuments
        }
        
        // ── 0) 복호화된 아카이브를 위한 임시 URL
        let decryptedArchiveURL = fm.temporaryDirectory
            .appendingPathComponent("Decrypted_Backup.aar")
        // 기존에 남아있으면 삭제
        try? fm.removeItem(at: decryptedArchiveURL)
        
        // ── 1) 암호화된 archiveURL 을 복호화하여 decryptedArchiveURL 에 쓰기
        try EncryptionManager.shared.decryptFile(at: archiveURL, to: decryptedArchiveURL)
        
        // ── 2) 이제 decryptedArchiveURL 을 이용해 압축 풀기
        let tmp = fm.temporaryDirectory.appendingPathComponent("NoteFlow_Backup", isDirectory: true)
        try? fm.removeItem(at: tmp)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        try FileManagerManager.shared.decompressArchive(decryptedArchiveURL, to: tmp)
        
        // 2) Core Data 스토어(.sqlite) 병합
        let coreBackupDir = tmp.appendingPathComponent("CoreData", isDirectory: true)
        let sqliteURL = coreBackupDir.appendingPathComponent("ChordLululala.sqlite")
        try CoreDataManager.shared.mergeBackupStore(at: sqliteURL)
        
        // 3) merge된 Content 엔티티를 sync-fetch
        let allContents = ContentCoreDataManager.shared.fetchContentsSync()
        
        // 4) Content.path 기준으로 파일 복원
        for content in allContents {
            guard let relPath = content.path, !relPath.isEmpty else { continue }
            let src = tmp.appendingPathComponent(relPath)
            let dst = docs.appendingPathComponent(relPath)
            
            // (a) 필요한 폴더가 없으면 생성
            let folder = (relPath as NSString).deletingLastPathComponent
            if !folder.isEmpty {
                _ = FileManagerManager.shared.createSubfolderIfNeeded(for: folder)
            }
            
            // (b) 백업에만 있고, 대상에 없을 때만 복사
            if fm.fileExists(atPath: src.path) && !fm.fileExists(atPath: dst.path) {
                try fm.copyItem(at: src, to: dst)
            }
        }
        
        // 5) 임시 폴더 정리 (선택)
        try? fm.removeItem(at: tmp)
    }
}
