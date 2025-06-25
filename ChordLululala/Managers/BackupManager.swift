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
        
        // 3) Score 복사
        for name in ["Score"] {
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
        // 5) 암호화
        try EncryptionManager.shared.encryptFile(at: archiveURL, to: archiveURL)
        // 6) 무결성 검사용 MAC 파일 생성
        let macURL = archiveURL.appendingPathExtension("mac")
        try EncryptionManager.shared.generateMACFile(at: archiveURL, to: macURL)
        
        return archiveURL
    }
    
    /// 백업 복원
    func restoreBackup(from archiveURL: URL) throws {
        print("⏳ [restoreBackup] 시작")
        try CoreDataManager.shared.backfillAllEntityIDs()
        
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ [restoreBackup] Documents 폴더 없음")
            throw BackupError.missingDocuments
        }
        
        let decryptedArchiveURL = fm.temporaryDirectory
            .appendingPathComponent("Decrypted_Backup.aar")
        try? fm.removeItem(at: decryptedArchiveURL)
        
        // 1) 무결성 검증
        let macURL = archiveURL.appendingPathExtension("mac")
        try EncryptionManager.shared.verifyMACFile(at: archiveURL, macURL: macURL)
        // 2) 복호화
        print("🔓 [restoreBackup] 백업 파일 복호화")
        try EncryptionManager.shared.decryptFile(at: archiveURL, to: decryptedArchiveURL)
        
        let tmp = fm.temporaryDirectory.appendingPathComponent("NoteFlow_Backup", isDirectory: true)
        try? fm.removeItem(at: tmp)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        print("📦 [restoreBackup] 압축 해제")
        try FileManagerManager.shared.decompressArchive(decryptedArchiveURL, to: tmp)
        
        let coreBackupDir = tmp.appendingPathComponent("CoreData", isDirectory: true)
        let sqliteURL = coreBackupDir.appendingPathComponent("ChordLululala.sqlite")
        print("🗄️ [restoreBackup] CoreData 병합 시작: \(sqliteURL.path)")
        try CoreDataManager.shared.mergeBackupStore(at: sqliteURL)
        
        let allContents = ContentCoreDataManager.shared.fetchContentsSync()
        print("📋 [restoreBackup] merge 후 Content 개수:", allContents.count)
        
        var copiedCount = 0
        var skippedCount = 0
        
        for content in allContents {
            guard let relPath = content.path, !relPath.isEmpty else { continue }
            let src = tmp.appendingPathComponent(relPath)
            let dst = docs.appendingPathComponent(relPath)
            
            let folder = (relPath as NSString).deletingLastPathComponent
            if !folder.isEmpty {
                _ = FileManagerManager.shared.createSubfolderIfNeeded(for: folder)
            }
            
            if fm.fileExists(atPath: src.path) && !fm.fileExists(atPath: dst.path) {
                do {
                    try fm.copyItem(at: src, to: dst)
                    print("✅ [restoreBackup] 복사됨: \(relPath)")
                    copiedCount += 1
                } catch {
                    print("❗️ [restoreBackup] 복사 실패: \(relPath) -> \(error)")
                }
            } else {
                skippedCount += 1
                if !fm.fileExists(atPath: src.path) {
                    print("⚠️ [restoreBackup] 백업 소스 없음: \(relPath)")
                } else {
                    print("🟡 [restoreBackup] 이미 파일 존재(스킵): \(relPath)")
                }
            }
        }
        
        print("🔚 [restoreBackup] 복사 완료 - 실제 복사: \(copiedCount)개, 스킵: \(skippedCount)개")
        
        try? fm.removeItem(at: tmp)
        print("🧹 [restoreBackup] 임시 폴더 정리 완료")
    }
}
