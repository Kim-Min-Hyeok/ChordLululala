//
//  FileManagerManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import Foundation

final class FileManagerManager {
    static let shared = FileManagerManager()
    private let fileManager = FileManager.default
    
    // Documents 디렉토리 URL 반환
    var documentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    
    /// Documents 폴더 기준 절대 경로에서 상대 경로를 추출
    func relativePath(for absolutePath: String) -> String? {
        guard let docsURL = documentsURL else { return nil }
        let docsPath = docsURL.path
        if absolutePath.hasPrefix(docsPath) {
            let startIndex = absolutePath.index(absolutePath.startIndex, offsetBy: docsPath.count + 1)
            return String(absolutePath[startIndex...])
        }
        return nil
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
}
