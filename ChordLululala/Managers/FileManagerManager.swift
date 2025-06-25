//
//  FileManagerManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import Foundation
import AppleArchive
import System

enum ArchiveError: Error {
    case cannotOpen
    case processFailed(Error)
}
final class FileManagerManager {
    static let shared = FileManagerManager()
    private let fileManager = FileManager.default
    
    // Documents 디렉토리 URL 반환
    var documentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    
    /// Documents 폴더 기준 절대 경로에서 상대 경로를 추출
    func relativePath(for absolutePath: String) -> String? {
        guard let docsURL = documentsURL?.standardizedFileURL else { return nil }

        let fileURL = URL(fileURLWithPath: absolutePath).standardizedFileURL
        let filePath = fileURL.path
        let docsPath = docsURL.path

        guard filePath.hasPrefix(docsPath) else {
            print("📛 상대 경로 변환 실패: \(filePath) is not under \(docsPath)")
            return nil
        }

        let relative = filePath.replacingOccurrences(of: docsPath + "/", with: "")
        return relative
    }
    
    func createSubfolderIfNeeded(for relativeFolderPath: String) -> URL? {
        guard let baseFolder = documentsURL else { return nil }
        let targetFolder = baseFolder.appendingPathComponent(relativeFolderPath, isDirectory: true)
        if !fileManager.fileExists(atPath: targetFolder.path) {
            do {
                try fileManager.createDirectory(at: targetFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("서브 폴더 생성 실패: \(error)")
                return nil
            }
        }
        return targetFolder
    }
    
    /// 파일 복사: Documents 폴더 기준으로 상대 폴더 경로를 덧붙여 복사
    func copyFile(from sourceURL: URL, relativeFolderPath: String? = nil) -> URL? {
        guard let baseFolder = documentsURL else { return nil }
        var destinationFolder = baseFolder
        if let folderPath = relativeFolderPath, !folderPath.isEmpty {
            if let subFolder = createSubfolderIfNeeded(for: folderPath) {
                destinationFolder = subFolder
            }
        }
        let destinationURL = destinationFolder.appendingPathComponent(sourceURL.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            if fileManager.fileExists(atPath: destinationURL.path) {
                return destinationURL
            } else {
                print("파일 복사 후 파일이 존재하지 않습니다: \(destinationURL.path)")
                return nil
            }
        } catch {
            print("파일 복사 실패: \(error)")
            return nil
        }
    }
    
    func deleteAllFilesInDocumentsFolder() {
        guard let documentsURL = documentsURL else { return }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try fileManager.removeItem(at: url)
            }
            print("Documents 내 모든 파일 삭제 완료")
        } catch {
            print("Documents 폴더 파일 삭제 실패: \(error)")
        }
    }

    // MARK: 백업 관련
    func compressDirectory(_ src: URL, toArchive dst: URL) throws {
            guard let writeStream = ArchiveByteStream.fileStream(
                    path: FilePath(dst.path),
                    mode: .writeOnly,
                    options: [.create, .truncate],
                    permissions: FilePermissions(rawValue: 0o644)
            ),
            let encoder = ArchiveStream.encodeStream(writingTo: writeStream)
            else { throw ArchiveError.cannotOpen }
            defer {
                try? encoder.close()
                try? writeStream.close()
            }
            let keySet = ArchiveHeader.FieldKeySet("TYP,PAT,DAT,UID,GID,MOD")!
            try encoder.writeDirectoryContents(archiveFrom: FilePath(src.path), keySet: keySet)
        }

        /// `.aar` 압축 해제
        func decompressArchive(_ src: URL, to dst: URL) throws {
            guard let readStream = ArchiveByteStream.fileStream(
                    path: FilePath(src.path),
                    mode: .readOnly,
                    options: [],
                    permissions: FilePermissions(rawValue: 0o644)
            ),
            let decomp = ArchiveByteStream.decompressionStream(readingFrom: readStream),
            let decode = ArchiveStream.decodeStream(readingFrom: decomp),
            let extract = ArchiveStream.extractStream(extractingTo: FilePath(dst.path))
            else { throw ArchiveError.cannotOpen }
            defer {
                try? readStream.close()
                try? decomp.close()
                try? decode.close()
                try? extract.close()
            }
            _ = try ArchiveStream.process(readingFrom: decode, writingTo: extract)
        }
    
    func mergeContents(of src: URL, into dst: URL) throws {
        let items = try fileManager.contentsOfDirectory(at: src, includingPropertiesForKeys: nil)
        if !fileManager.fileExists(atPath: dst.path) {
            try fileManager.createDirectory(at: dst, withIntermediateDirectories: true)
            }
            for file in items {
                let target = dst.appendingPathComponent(file.lastPathComponent)
                if !fileManager.fileExists(atPath: target.path) {
                    try fileManager.copyItem(at: file, to: target)
                }
            }
        }
}
