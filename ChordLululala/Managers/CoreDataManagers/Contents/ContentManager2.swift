//
//  ContentManager2.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/24/25.
//

import SwiftUI
import Combine

struct ContentManager2 {
    static let shared = ContentManager2()
    
    func loadContentModels(forParent parent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<[ContentModel], Error> {
        return ContentCoreDataManager.shared
            .loadContentModels(forParent: parent, dashboardContents: dashboardContents)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // 파일 업로드 – 작업 완료 시 Void 발행
    func uploadFile(with url: URL, currentParent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            let relativeFolderPath = currentParent?.path
            ContentFileManagerManager.shared.uploadFile(from: url,
                                                        to: dashboardContents,
                                                        relativeFolderPath: relativeFolderPath) { result in
                switch result {
                case .success((let destinationURL, let relativePath)):
                    // 파일 복사가 성공하면 CoreData에 콘텐츠 생성
                    ContentCoreDataManager.shared.createContent(name: destinationURL.lastPathComponent,
                                                                path: relativePath,
                                                                type: ContentType.score.rawValue,
                                                                category: ContentCategory.score.rawValue,
                                                                parent: currentParent?.cid,
                                                                s_dids: nil)
                case .failure(let error):
                    print("파일 업로드 실패: \(error)")
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 폴더 생성 – 작업 완료 시 Void 발행
    func createFolder(folderName: String,
                      currentParent: ContentModel?,
                      dashboardContents: DashboardContents) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            guard let currentParent = currentParent else { promise(.success(())); return }
            ContentFileManagerManager.shared.createFolder(named: folderName,
                                                          relativeTo: currentParent,
                                                          dashboardContents: dashboardContents) { result in
                switch result {
                case .success((_, let newRelativePath)):
                    // 파일 시스템 작업이 성공하면 CoreData에 폴더 콘텐츠 생성
                    ContentCoreDataManager.shared.createContent(name: folderName,
                                                                path: newRelativePath,
                                                                type: ContentType.folder.rawValue,
                                                                category: currentParent.category.rawValue,
                                                                parent: currentParent.cid,
                                                                s_dids: nil)
                case .failure(let error):
                    print("폴더 생성 실패: \(error)")
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 이름 수정 – 작업 완료 시 Void 발행
    func renameContent(_ model: ContentModel, newName: String) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            var updatedModel = model
            let isFile = updatedModel.type != .folder
            let updatedName = isFile ? newName + ".pdf" : newName
            updatedModel.name = updatedName
            updatedModel.modifiedAt = Date()
            updatedModel.lastAccessedAt = Date()
            
            if let oldPath = updatedModel.path,
               let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let oldURL = docsURL.appendingPathComponent(oldPath)
                let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(updatedName)
                
                ContentFileManagerManager.shared.renameItem(at: oldURL, to: newURL) { result in
                    switch result {
                    case .success(let newRelativePath):
                        updatedModel.path = newRelativePath
                        ContentCoreDataManager.shared.updateContent(model: updatedModel)
                    case .failure(let error):
                        print("파일/폴더 이름 변경 실패: \(error)")
                    }
                    promise(.success(()))
                }
            } else {
                ContentCoreDataManager.shared.updateContent(model: updatedModel)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 휴지통 이동 – 작업 완료 시 Void 발행
    func moveContentToTrash(_ model: ContentModel, performPhysicalMove: Bool = true) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            var updatedModel = model
            
            ContentCoreDataManager.shared.moveContentToTrash(&updatedModel)
            
            guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                  let trashURL = ContentFileManagerManager.shared.documentsURL?.appendingPathComponent("Trash_Can", isDirectory: true)
            else { promise(.success(())); return }
            
            if performPhysicalMove {
                if !FileManager.default.fileExists(atPath: trashURL.path) {
                    do {
                        try FileManager.default.createDirectory(at: trashURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Trash_Can 폴더 생성 실패: \(error)")
                        promise(.success(()))
                        return
                    }
                }
                
                if updatedModel.type == .folder {
                    guard let oldPath = updatedModel.path else { promise(.success(())); return }
                    let oldURL = docsURL.appendingPathComponent(oldPath)
                    guard FileManager.default.fileExists(atPath: oldURL.path) else {
                        print("원본 폴더가 존재하지 않습니다: \(oldURL.path)")
                        promise(.success(()))
                        return
                    }
                    let newURL = trashURL.appendingPathComponent(oldURL.lastPathComponent)
                    do {
                        if FileManager.default.fileExists(atPath: newURL.path) {
                            try FileManager.default.removeItem(at: newURL)
                        }
                        try FileManager.default.moveItem(at: oldURL, to: newURL)
                        if let newRelativePath = ContentFileManagerManager.shared.relativePath(for: newURL.path) {
                            updatedModel.path = newRelativePath
                        }
                    } catch {
                        print("폴더 휴지통 이동 실패: \(error)")
                    }
                } else {
                    guard let oldPath = updatedModel.path else { promise(.success(())); return }
                    let sourceURL = docsURL.appendingPathComponent(oldPath)
                    guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                        print("원본 파일이 존재하지 않습니다: \(sourceURL.path)")
                        promise(.success(()))
                        return
                    }
                    let destinationURL = trashURL.appendingPathComponent(sourceURL.lastPathComponent)
                    do {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                        if let newRelativePath = ContentFileManagerManager.shared.relativePath(for: destinationURL.path) {
                            updatedModel.path = newRelativePath
                        }
                    } catch {
                        print("파일 휴지통 이동 실패: \(error)")
                    }
                }
            }
            
            // 최상위 항목은 이미 CoreData 측에서 업데이트됨.
            ContentManager.shared.updateContent(model: updatedModel)
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    
    // 복제 – 작업 완료 시 Void 발행
    func duplicateContent(_ model: ContentModel, newParent: UUID? = nil, dashboardContents: DashboardContents) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            if model.type == .folder {
                let targetParent = newParent ?? model.parent
                let newFolderName = (newParent == nil) ? self.generateDuplicateFolderName(for: model) : model.name
                
                guard let baseFolder = ContentFileManagerManager.shared.baseFolderURL(for: dashboardContents),
                      let oldPath = model.path else { promise(.success(())); return }
                
                let newParentRelativePath: String?
                if let newParent = newParent,
                   let parentModel = ContentManager.shared.fetchContentModel(with: newParent) {
                    newParentRelativePath = parentModel.path
                } else {
                    newParentRelativePath = nil
                }
                
                switch ContentFileManagerManager.shared.duplicateFolder(oldFolderPath: oldPath, newFolderName: newFolderName, newParentRelativePath: newParentRelativePath, dashboardContents: dashboardContents) {
                case .success(let newFolderURL):
                    guard let newRelativePath = ContentFileManagerManager.shared.relativePath(for: newFolderURL.path) else { promise(.success(())); return }
                    let newFolderModel = ContentModel(cid: UUID(),
                                                      name: newFolderName,
                                                      path: newRelativePath,
                                                      type: .folder,
                                                      category: model.category,
                                                      parent: targetParent,
                                                      createdAt: Date(),
                                                      modifiedAt: Date(),
                                                      lastAccessedAt: Date(),
                                                      deletedAt: nil,
                                                      isTrash: false,
                                                      originalParentId: targetParent,
                                                      syncStatus: false,
                                                      s_dids: nil)
                    ContentManager.shared.createContent(model: newFolderModel)
                    
                    let children = ContentManager.shared.fetchChildrenModels(for: model.cid)
                    for child in children {
                        _ = self.duplicateContent(child, newParent: newFolderModel.cid, dashboardContents: dashboardContents)
                            .sink { }
                    }
                case .failure(let error):
                    print("폴더 복제 실패: \(error)")
                }
            } else {
                let newName = (newParent == nil) ? self.generateDuplicateFileName(for: model, dashboardContents: dashboardContents) : model.name
                guard let baseFolder = ContentFileManagerManager.shared.baseFolderURL(for: dashboardContents),
                      let relativePath = model.path else { promise(.success(())); return }
                
                let newParentRelativePath: String?
                if let newParent = newParent,
                   let parentModel = ContentManager.shared.fetchContentModel(with: newParent) {
                    newParentRelativePath = parentModel.path
                } else {
                    newParentRelativePath = nil
                }
                
                switch ContentFileManagerManager.shared.duplicateFile(oldFilePath: relativePath, newFileName: newName, newParentRelativePath: newParentRelativePath, dashboardContents: dashboardContents) {
                case .success(let destinationURL):
                    guard let newRelativePath = ContentFileManagerManager.shared.relativePath(for: destinationURL.path) else { promise(.success(())); return }
                    let newFileModel = ContentModel(cid: UUID(),
                                                    name: newName,
                                                    path: newRelativePath,
                                                    type: model.type,
                                                    category: model.category,
                                                    parent: newParent ?? model.parent,
                                                    createdAt: Date(),
                                                    modifiedAt: Date(),
                                                    lastAccessedAt: Date(),
                                                    deletedAt: nil,
                                                    isTrash: false,
                                                    originalParentId: newParent ?? model.parent,
                                                    syncStatus: false,
                                                    s_dids: nil)
                    ContentManager.shared.createContent(model: newFileModel)
                case .failure(let error):
                    print("파일 복제 실패: \(error)")
                }
            }
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    // 삭제 – 작업 완료 시 Void 발행
    func deleteContent(_ content: ContentModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            if content.type == .folder {
                let children = ContentManager.shared.fetchChildrenModels(for: content.cid)
                for child in children {
                    _ = self.deleteContent(child)
                        .sink { }
                }
            }
            if let path = content.path,
               let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let itemURL = docsURL.appendingPathComponent(path)
                if FileManager.default.fileExists(atPath: itemURL.path) {
                    do {
                        try FileManager.default.removeItem(at: itemURL)
                        print("파일 시스템에서 삭제 성공: \(itemURL.path)")
                    } catch {
                        print("파일 시스템 삭제 실패 (\(itemURL.path)): \(error)")
                    }
                } else {
                    print("삭제할 파일/폴더가 존재하지 않습니다: \(itemURL.path)")
                }
            }
            ContentManager.shared.deleteContent(model: content)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper 함수들
    private func generateDuplicateFileName(for model: ContentModel, dashboardContents: DashboardContents) -> String {
        guard model.type != .folder, let originalName = model.name as String? else { return "Unnamed.pdf" }
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        var index = 1
        var newName = "\(baseName) (\(index)).\(ext)"
        if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let oldPath = model.path {
            let originalFileURL = docsURL.appendingPathComponent(oldPath)
            let parentDirectory = originalFileURL.deletingLastPathComponent()
            while FileManager.default.fileExists(atPath: parentDirectory.appendingPathComponent(newName).path) {
                index += 1
                newName = "\(baseName) (\(index)).\(ext)"
            }
        }
        return newName
    }
    
    private func generateDuplicateFolderName(for model: ContentModel) -> String {
        let baseName = model.name
        var index = 1
        var newName = "\(baseName) (\(index))"
        let siblings = ContentManager.shared.fetchChildrenModels(for: model.parent)
        while siblings.contains(where: { $0.name == newName }) {
            index += 1
            newName = "\(baseName) (\(index))"
        }
        return newName
    }
}
