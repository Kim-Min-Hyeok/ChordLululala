//
//  FileManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import Foundation

final class FileManagerManager {
    static let shared = FileManagerManager()
    private let fileManager = FileManager.default
    
    // 앱의 Documents 디렉토리 URL
    private var documentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // Score 폴더 URL (PDF 파일 저장)
    var scoreFolderURL: URL? {
        guard let documentsURL = documentsURL else { return nil }
        return documentsURL.appendingPathComponent("Score", isDirectory: true)
    }
    
    // Song_List 폴더 URL (JSON 파일 저장, 접근 제한)
    var songListFolderURL: URL? {
        guard let documentsURL = documentsURL else { return nil }
        return documentsURL.appendingPathComponent("Song_List", isDirectory: true)
    }
    
    // Trash_Can 폴더 URL (삭제된 파일 저장, 접근 제한)
    var trashCanFolderURL: URL? {
        guard let documentsURL = documentsURL else { return nil }
        return documentsURL.appendingPathComponent("Trash_Can", isDirectory: true)
    }
    
    // Score 폴더가 존재하는지 확인하고, 없으면 생성
    func createScoreFolderIfNeeded() -> URL? {
        guard let scoreFolderURL = scoreFolderURL else { return nil }
        if !fileManager.fileExists(atPath: scoreFolderURL.path) {
            do {
                try fileManager.createDirectory(at: scoreFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Score 폴더 생성 실패: \(error)")
                return nil
            }
        }
        return scoreFolderURL
    }
    
    func copyPDFToScoreFolder(from sourceURL: URL) -> URL? {
        guard let scoreFolder = createScoreFolderIfNeeded() else { return nil }
        let destinationURL = scoreFolder.appendingPathComponent(sourceURL.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            // 복사 후 파일 존재 여부 확인
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
    
    // 상대경로를 통해 빌드 후에 절대 경로가 달라지는 것을 보완
    func relativePath(for absolutePath: String) -> String? {
        guard let docsURL = documentsURL else { return nil }
        let docsPath = docsURL.path
        if absolutePath.hasPrefix(docsPath) {
            let startIndex = absolutePath.index(absolutePath.startIndex, offsetBy: docsPath.count + 1)
            return String(absolutePath[startIndex...])
        }
        return nil
    }
    
    // TODO: 테스트용 모든 데이터 삭제 (Score)
    func deleteAllFilesInScoreFolder() {
        guard let scoreFolderURL = FileManagerManager.shared.scoreFolderURL else { return }
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: scoreFolderURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Score 폴더 파일 삭제 실패: \(error)")
        }
    }
    
}
