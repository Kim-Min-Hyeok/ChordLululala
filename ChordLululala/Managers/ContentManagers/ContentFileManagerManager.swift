//
//  ContentCoreDataManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Foundation
import Combine

enum FileServiceError: Error {
    case baseFolderNotFound
    case fileCopyFailed
    case relativePathNotFound
    case folderCreationFailed
}

final class ContentFileManagerManager {
    static let shared = ContentFileManagerManager()
    
    // MARK: - Create
    // 파일 생성 (업로드)
    func uploadFile(from url:  URL,
                    to dashboardContents: DashboardContents,
                    relativeFolderPath: String?,
                    completion: @escaping (Result<(destinationURL: URL, relativePath: String), FileServiceError>) -> Void) {
        
        // 파일 복사: FileManagerManager에 해당 로직을 위임합니다.
        DispatchQueue.global(qos: .userInitiated).async {
            if let destinationURL = FileManagerManager.shared.copyFile(from: url,
                                                                                  relativeFolderPath: relativeFolderPath),
               let relativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
                completion(.success((destinationURL, relativePath)))
            } else {
                completion(.failure(.fileCopyFailed))
            }
        }
    }
    
    // 폴더 생성
    func createFolder(named folderName: String,
                      relativeTo currentParent: Content?,
                      dashboardContents: DashboardContents,
                      completion: @escaping (Result<(folderURL: URL, relativePath: String), FileServiceError>) -> Void) {
        
        let parentRelativePath = currentParent?.path ?? ""
        let relativeFolderPath = parentRelativePath.isEmpty
        ? folderName
        : (parentRelativePath as NSString).appendingPathComponent(folderName)
        
        // 서브폴더 생성
        DispatchQueue.global(qos: .userInitiated).async {
            if let newFolderURL = FileManagerManager.shared.createSubfolderIfNeeded(for: relativeFolderPath),
               let newRelativePath = self.relativePath(for: newFolderURL.path) {
                completion(.success((folderURL: newFolderURL, relativePath: newRelativePath)))
            } else {
                completion(.failure(.folderCreationFailed))
            }
        }
    }
    
    // 지정된 URL에 폴더가 없으면 생성
    func createFolderIfNeeded(at url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    DispatchQueue.main.async { completion(.success(())) }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            } else {
                DispatchQueue.main.async { completion(.success(())) }
            }
        }
    }
    
    // MARK: - Read
    // 상대 경로 반환
    func relativePath(for absolutePath: String) -> String? {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let docsPath = docsURL.path
        if absolutePath.hasPrefix(docsPath) {
            let relativePath = String(absolutePath.dropFirst(docsPath.count + 1))
            return relativePath
        }
        return nil
    }
    
    // document 폴더 반환
    func baseFolderURL(for dashboardContents: DashboardContents) -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    
    // Documents 폴더 내 "Trash_Can" 폴더의 URL을 반환
    func trashURL() -> URL? {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docsURL.appendingPathComponent("Trash_Can", isDirectory: true)
    }
    
    // MARK: - Update
    // 이름 수정
    func renameItem(at oldURL: URL, to newURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = self.relativePath(for: newURL.path) {
                    DispatchQueue.main.async {
                        completion(.success(newRelativePath))
                    }
                } else {
                    throw NSError(domain: "ContentFileManagerManager",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "상대 경로 계산 실패"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // 파일 또는 폴더를 sourceURL에서 destinationURL로 이동시키고, 이동 후의 새 상대 경로를 반환
    func moveItem(from sourceURL: URL, to destinationURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                if let newRelativePath = self.relativePath(for: destinationURL.path) {
                    DispatchQueue.main.async { completion(.success(newRelativePath)) }
                } else {
                    throw NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "상대경로 변환 실패"])
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    // 파일 시스템 상에서 oldPath(상대 경로)에 해당하는 항목을 "Trash_Can" 폴더로 이동시키고, 새 상대 경로를 반환
    func moveContentToTrash(oldPath: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let trashFolder = trashURL() else {
            completion(.failure(NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey:"폴더 URL 오류"])))
            return
        }
        
        // Trash_Can 폴더 생성 (없으면 생성)
        createFolderIfNeeded(at: trashFolder) { result in
            switch result {
            case .success:
                let sourceURL = docsURL.appendingPathComponent(oldPath)
                let destinationURL = trashFolder.appendingPathComponent(sourceURL.lastPathComponent)
                self.moveItem(from: sourceURL, to: destinationURL, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 복제
    // 폴더 복제
    func duplicateFolder(oldFolderPath: String, newFolderName: String, newParentRelativePath: String?, dashboardContents: DashboardContents) -> Result<URL, Error> {
        guard let baseFolder = baseFolderURL(for: dashboardContents) else {
            return .failure(NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base folder 없음"]))
        }
        
        // 기존 폴더 URL
        let sourceFolderURL = baseFolder.appendingPathComponent(oldFolderPath, isDirectory: true)
        let destinationParentURL: URL
        if let newParentRelativePath = newParentRelativePath {
            destinationParentURL = baseFolder.appendingPathComponent(newParentRelativePath, isDirectory: true)
        } else {
            destinationParentURL = sourceFolderURL.deletingLastPathComponent()
        }
        let destinationURL = destinationParentURL.appendingPathComponent(newFolderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            return .success(destinationURL)
        } catch {
            return .failure(error)
        }
    }
    
    // 파일 복제
    func duplicateFile(oldFilePath: String, newFileName: String, newParentRelativePath: String?, dashboardContents: DashboardContents) -> Result<URL, Error> {
        guard let baseFolder = baseFolderURL(for: dashboardContents) else {
            return .failure(NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base folder 없음"]))
        }
        
        let sourceFileURL = baseFolder.appendingPathComponent(oldFilePath)
        let destinationParentURL: URL
        if let newParentRelativePath = newParentRelativePath {
            destinationParentURL = baseFolder.appendingPathComponent(newParentRelativePath, isDirectory: true)
        } else {
            destinationParentURL = sourceFileURL.deletingLastPathComponent()
        }
        let destinationURL = destinationParentURL.appendingPathComponent(newFileName)
        
        do {
            guard FileManager.default.fileExists(atPath: sourceFileURL.path) else {
                throw NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "원본 파일이 존재하지 않음"])
            }
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceFileURL, to: destinationURL)
            return .success(destinationURL)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Delete
    func deleteItem(atRelativePath relativePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(.failure(NSError(domain: "ContentFileManagerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Documents 폴더 없음"])))
            return
        }
        let itemURL = docsURL.appendingPathComponent(relativePath)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if FileManager.default.fileExists(atPath: itemURL.path) {
                do {
                    try FileManager.default.removeItem(at: itemURL)
                    DispatchQueue.main.async {
                        print("파일 시스템에서 삭제 성공: \(itemURL.path)")
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("파일 시스템 삭제 실패 (\(itemURL.path)): \(error)")
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("삭제할 파일/폴더가 존재하지 않습니다: \(itemURL.path)")
                    completion(.success(()))
                }
            }
        }
    }
}
