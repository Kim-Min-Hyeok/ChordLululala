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
    
    /// 기본 폴더 URL을 Documents 폴더로 설정합니다.
    /// 이후 파일이나 폴더 생성 시, Core Data에 저장된 Content 객체의 path를 그대로 사용하여 Documents 하위에 경로를 구성합니다.
    func baseFolderURL(for category: DashboardContents) -> URL? {
        return documentsURL // 항상 Documents 폴더 기준
    }
    
    /// 지정한 상대 경로(예: "Score" 또는 "Score/SubFolder")에 해당하는 폴더가 Documents 폴더 기준으로 존재하지 않으면 생성하고, 생성된 폴더 URL을 반환합니다.
    func createSubfolderIfNeeded(for relativeFolderPath: String, inBaseFolder baseFolder: URL?) -> URL? {
        guard let baseFolder = baseFolder else { return nil }
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
    
    /// 파일 복사: Documents 폴더 기준으로 상대 폴더 경로를 덧붙여 복사합니다.
    func copyPDFToBaseFolder(from sourceURL: URL, relativeFolderPath: String? = nil, baseFolder: URL?) -> URL? {
        guard let baseFolder = baseFolder else { return nil }
        var destinationFolder = baseFolder
        if let folderPath = relativeFolderPath, !folderPath.isEmpty {
            if let subFolder = createSubfolderIfNeeded(for: folderPath, inBaseFolder: baseFolder) {
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
    
    /// Documents 폴더 기준 절대 경로에서 상대 경로를 추출합니다.
    func relativePath(for absolutePath: String) -> String? {
        guard let docsURL = documentsURL else { return nil }
        let docsPath = docsURL.path
        if absolutePath.hasPrefix(docsPath) {
            let startIndex = absolutePath.index(absolutePath.startIndex, offsetBy: docsPath.count + 1)
            return String(absolutePath[startIndex...])
        }
        return nil
    }
    
    func deleteAllFilesInScoreFolder() {
        guard let scoreURL = documentsURL?.appendingPathComponent("Score", isDirectory: true) else { return }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: scoreURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Score 폴더 파일 삭제 실패: \(error)")
        }
    }
}
