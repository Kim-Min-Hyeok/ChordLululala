//
//  ContentManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/24/25.
//

import SwiftUI
import Combine

struct ContentManager {
    static let shared = ContentManager()
    
    func initializeBaseDirectories() ->  Void {
        ContentCoreDataManager.shared.initializeBaseDirectories()
    }
    
    func fetchBaseDirectory(named name: String) -> ContentModel? {
        return ContentCoreDataManager.shared.fetchBaseDirectory(named: name)
    }
    
    func fetchContentModel(with id: UUID) -> ContentModel? {
        return ContentCoreDataManager.shared.fetchContentModel(with: id)
    }
    
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
                                                                parent: currentParent?.cid,
                                                                scoreDetail: nil)
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
            guard let currentParent = currentParent else {
                promise(.success(()))
                return
            }
            ContentFileManagerManager.shared.createFolder(named: folderName,
                                                          relativeTo: currentParent,
                                                          dashboardContents: dashboardContents) { (result: Result<(folderURL: URL, relativePath: String), FileServiceError>) in
                switch result {
                case .success(let folderResult):
                    // folderResult는 (folderURL, relativePath) 튜플로 반환됨
                    let newRelativePath = folderResult.relativePath
                    // 파일 시스템 작업이 성공하면 CoreData에 폴더 콘텐츠 생성
                    ContentCoreDataManager.shared.createContent(name: folderName,
                                                                path: newRelativePath,
                                                                type: ContentType.folder.rawValue,
                                                                parent: currentParent.cid,
                                                                scoreDetail: nil)
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
    
    // 파일 이동
    func moveContent(_ content: ContentModel, to destination: ContentModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            guard
                let oldRel = content.path,
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                promise(.success(()))
                return
            }
            
            let sourceURL = docsURL.appendingPathComponent(oldRel)
            
            guard let destRel = destination.path else {
                print("Destination path is nil")
                promise(.success(()))
                return
            }
            
            let destFolderURL = docsURL.appendingPathComponent(destRel, isDirectory: true)
            
            let newURL = destFolderURL.appendingPathComponent(content.name)
            
            ContentFileManagerManager.shared.moveItem(from: sourceURL, to: newURL) { result in
                switch result {
                case .success(let newRel):
                    var updated = content
                    updated.path = newRel
                    updated.parentContent = destination.cid
                    ContentCoreDataManager.shared.updateContent(model: updated)
                case .failure(let error):
                    print("Move failed:", error)
                }
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
                  let trashURL = ContentFileManagerManager.shared.trashURL()
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
            ContentCoreDataManager.shared.updateContent(model: updatedModel)
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    // 복구
    func restoreContent(_ content: ContentModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1. 복구를 위해 originalParentId가 필요함
            guard let originalParentId = content.originalParentId,
                  let originalParentContent = ContentCoreDataManager.shared.fetchContentModel(with: originalParentId),
                  let parentFolderRelativePath = originalParentContent.path,
                  !parentFolderRelativePath.isEmpty else {
                print("복구할 원본 부모 정보 또는 경로가 없습니다.")
                promise(.success(()))
                return
            }
            
            // 2. 현재 Content의 파일 경로(휴지통 내 상대경로)가 필요함
            guard let currentRelativePath = content.path, !currentRelativePath.isEmpty,
                  let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("현재 Content의 파일 경로가 없습니다.")
                promise(.success(()))
                return
            }
            
            // 3. 현재 파일의 절대 URL (휴지통 내 위치)
            let sourceURL = docsURL.appendingPathComponent(currentRelativePath)
            
            // 4. 복구 대상 폴더(원래 부모 폴더)의 절대 URL 계산
            let destinationFolderURL = docsURL.appendingPathComponent(parentFolderRelativePath)
            let fileName = (currentRelativePath as NSString).lastPathComponent
            let destinationURL = destinationFolderURL.appendingPathComponent(fileName)
            
            // 5. ContentFileManagerManager의 moveItem을 통해 파일 이동 (복구)
            ContentFileManagerManager.shared.moveItem(from: sourceURL, to: destinationURL) { result in
                switch result {
                case .success(let newRelativePath):
                    // 6. 이동에 성공하면, CoreData의 Content를 업데이트하여 복구 완료 처리
                    var updatedContent = content
                    updatedContent.parentContent = originalParentContent.cid
                    updatedContent.deletedAt = nil
                    updatedContent.path = newRelativePath
                    
                    ContentCoreDataManager.shared.updateContent(model: updatedContent)
                    print("복구 성공: \(content.name)")
                    promise(.success(()))
                case .failure(let error):
                    print("복구 실패: \(error)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 복제 – 작업 완료 시 Void 발행
    func duplicateContent(_ model: ContentModel, newParent: UUID? = nil, dashboardContents: DashboardContents) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            if model.type == .folder {
                let targetParent = newParent ?? model.parentContent
                let newFolderName = (newParent == nil) ? ContentNamer.shared.generateDuplicateFolderName(for: model) : model.name
                
                guard let oldPath = model.path else { promise(.success(())); return }
                
                let newParentRelativePath: String?
                if let newParent = newParent,
                   let parentModel = ContentCoreDataManager.shared.fetchContentModel(with: newParent) {
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
                                                      parentContent: targetParent,
                                                      createdAt: model.modifiedAt,
                                                      modifiedAt: model.modifiedAt,
                                                      lastAccessedAt: model.modifiedAt,
                                                      deletedAt: nil,
                                                      originalParentId: targetParent,
                                                      syncStatus: false,
                                                      isStared: false,
                                                      scoreDetail: nil)
                    ContentCoreDataManager.shared.createContent(model: newFolderModel)
                    
                    let children = ContentCoreDataManager.shared.fetchChildrenModels(for: model.cid)
                    for child in children {
                        _ = self.duplicateContent(child, newParent: newFolderModel.cid, dashboardContents: dashboardContents)
                            .sink { }
                    }
                case .failure(let error):
                    print("폴더 복제 실패: \(error)")
                }
            } else {
                let newName = (newParent == nil) ? ContentNamer.shared.generateDuplicateFileName(for: model, dashboardContents: dashboardContents) : model.name
                guard let relativePath = model.path else { promise(.success(())); return }
                
                let newParentRelativePath: String?
                if let newParent = newParent,
                   let parentModel = ContentCoreDataManager.shared.fetchContentModel(with: newParent) {
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
                                                    parentContent: newParent ?? model.parentContent,
                                                    createdAt: model.modifiedAt,
                                                    modifiedAt: model.modifiedAt,
                                                    lastAccessedAt: model.modifiedAt,
                                                    deletedAt: nil,
                                                    originalParentId: newParent ?? model.parentContent,
                                                    syncStatus: false,
                                                    isStared: false,
                                                    scoreDetail: nil)
                    ContentCoreDataManager.shared.createContent(model: newFileModel)
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
            // 파일 시스템 삭제 (폴더 삭제 시 하위 파일/폴더도 함께 삭제됨)
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
            // CoreData에서 삭제 (Cascade Delete가 설정되어 있으므로 자식은 자동 삭제)
            ContentCoreDataManager.shared.deleteContent(model: content)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func toggleContentStared(_ content: ContentModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            ContentCoreDataManager.shared.toggleContentStared(model: content)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
