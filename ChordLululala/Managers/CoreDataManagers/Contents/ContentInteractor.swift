//
//  ContentInteractor.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Foundation
import Combine
import SwiftUI

final class ContentInteractor {
    static let shared = ContentInteractor()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Create
    // 파일 생성 (업로드)
    func uploadFile(with url: URL, currentParent: ContentModel?, dashboardContents: DashboardContents) {
        guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: dashboardContents) else { return }
        let relativeFolderPath = currentParent?.path
        if let destinationURL = FileManagerManager.shared.copyPDFToBaseFolder(from: url,
                                                                              relativeFolderPath: relativeFolderPath,
                                                                              baseFolder: baseFolder),
           let relativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
            ContentManager.shared.createContent(name: destinationURL.lastPathComponent,
                                                path: relativePath,
                                                type: ContentType.score.rawValue,
                                                category: ContentCategory.score.rawValue,
                                                parent: currentParent?.cid,
                                                s_dids: nil)
        }
    }
    
    // 폴더 생성
    func createFolder(folderName: String, currentParent: ContentModel?, dashboardContents: DashboardContents) {
        guard let currentParent = currentParent else { return }
        guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: dashboardContents) else { return }
        
        let parentRelativePath = currentParent.path ?? ""
        let relativeFolderPath = parentRelativePath.isEmpty
        ? folderName
        : (parentRelativePath as NSString).appendingPathComponent(folderName)
        
        if let newFolderURL = FileManagerManager.shared.createSubfolderIfNeeded(for: relativeFolderPath, inBaseFolder: baseFolder),
           let newRelativePath = FileManagerManager.shared.relativePath(for: newFolderURL.path) {
            ContentManager.shared.createContent(name: folderName,
                                                path: newRelativePath,
                                                type: ContentType.folder.rawValue,
                                                category: currentParent.category.rawValue,
                                                parent: currentParent.cid,
                                                s_dids: nil)
        }
    }
    
    // MARK: - Read
    func loadContentModels(forParent parent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<[ContentModel], Error> {
        var predicate: NSPredicate
        if let parentID = parent?.cid {
            predicate = NSPredicate(format: "parent == %@", parentID as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        
        switch dashboardContents {
        case .allDocuments:
            let trashPredicate = NSPredicate(format: "isTrash == NO")
            let categoryPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "category == %d", ContentCategory.score.rawValue)
            ])
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate, categoryPredicate])
            
        case .recentDocuments:
            let trashPredicate = NSPredicate(format: "isTrash == NO")
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let recentPredicate = NSPredicate(format: "lastAccessedAt >= %@", oneDayAgo as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate, recentPredicate])
            
        case .songList:
            let categoryPredicate = NSPredicate(format: "type == %d", ContentCategory.songList.rawValue)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
            
        case .trashCan:
            let trashPredicate = NSPredicate(format: "isTrash == YES")
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate])
        }
        
        return ContentManager.shared.fetchContentModelsPublisher(predicate: predicate)
    }
    
    // MARK: - Update
    // 1. 이름 수정
    func renameContent(_ model: ContentModel, newName: String) {
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
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    updatedModel.path = newRelativePath
                }
            } catch {
                print("파일/폴더 이름 변경 실패: \(error)")
            }
        }
        
        ContentManager.shared.updateContent(model: updatedModel)
    }
    
    // 2. 휴지통 이동
    func moveContentToTrash(_ model: ContentModel, performPhysicalMove: Bool = true) {
        var updatedModel = model
        updatedModel.category = .trash
        updatedModel.parent = ContentManager.shared.fetchBaseDirectory(named: "Trash_Can")?.cid
        updatedModel.modifiedAt = Date()
        updatedModel.lastAccessedAt = Date()
        updatedModel.deletedAt = Date()
        updatedModel.isTrash = true
        
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let trashURL = FileManagerManager.shared.documentsURL?.appendingPathComponent("Trash_Can", isDirectory: true)
        else { return }
        
        // 최상위 호출에서만 실제 파일 이동 수행
        if performPhysicalMove {
            // 휴지통 폴더 생성
            if !FileManager.default.fileExists(atPath: trashURL.path) {
                do {
                    try FileManager.default.createDirectory(at: trashURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Trash_Can 폴더 생성 실패: \(error)")
                    return
                }
            }
            
            if updatedModel.type == .folder {
                guard let oldPath = updatedModel.path else { return }
                let oldURL = docsURL.appendingPathComponent(oldPath)
                guard FileManager.default.fileExists(atPath: oldURL.path) else {
                    print("원본 폴더가 존재하지 않습니다: \(oldURL.path)")
                    return
                }
                let newURL = trashURL.appendingPathComponent(oldURL.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: newURL.path) {
                        try FileManager.default.removeItem(at: newURL)
                    }
                    try FileManager.default.moveItem(at: oldURL, to: newURL)
                    if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                        updatedModel.path = newRelativePath
                    }
                } catch {
                    print("폴더 휴지통 이동 실패: \(error)")
                }
            } else {
                guard let oldPath = updatedModel.path else { return }
                let sourceURL = docsURL.appendingPathComponent(oldPath)
                guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                    print("원본 파일이 존재하지 않습니다: \(sourceURL.path)")
                    return
                }
                let destinationURL = trashURL.appendingPathComponent(sourceURL.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                    if let newRelativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
                        updatedModel.path = newRelativePath
                    }
                } catch {
                    print("파일 휴지통 이동 실패: \(error)")
                }
            }
        }
        
        // 최상위 모델 CoreData 업데이트
        ContentManager.shared.updateContent(model: updatedModel)
        
        // 폴더라면 하위 항목들의 CoreData 경로 재계산 (재귀적 업데이트)
        if updatedModel.type == .folder {
            let children = ContentManager.shared.fetchChildrenModels(for: updatedModel.cid)
            for var child in children {
                // 하위 항목에도 동일한 휴지통 상태 적용
                child.category = .trash
                child.modifiedAt = Date()
                child.lastAccessedAt = Date()
                child.deletedAt = Date()
                child.isTrash = true
                
                // 경로 업데이트
                if let childPath = child.path,
                   let parentOldPath = model.path,
                   let parentNewPath = updatedModel.path {
                    let newChildPath = childPath.replacingOccurrences(of: parentOldPath, with: parentNewPath)
                    child.path = newChildPath
                }
                
                // 하위 항목 CoreData 업데이트
                ContentManager.shared.updateContent(model: child)
                
                // 하위 폴더인 경우 재귀 호출 (물리적 이동은 이미 처리됨)
                if child.type == .folder {
                    moveContentToTrash(child, performPhysicalMove: false)
                }
            }
        }
    }
    
    // MARK: - 복제 (파일은 복제, 폴더는 재귀 복제)
    func duplicateContent(_ model: ContentModel, newParent: UUID? = nil, dashboardContents: DashboardContents) {
        if model.type == .folder {
            let targetParent = newParent ?? model.parent
            let newFolderName = (newParent == nil)
            ? generateDuplicateFolderName(for: model)
            : model.name
            
            guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: dashboardContents),
                  let oldPath = model.path else { return }
            
            let newFolderURL: URL
            if let newParent = newParent,
               let parentModel = ContentManager.shared.fetchContentModel(with: newParent),
               let parentRelativePath = parentModel.path {
                let parentFolderURL = baseFolder.appendingPathComponent(parentRelativePath)
                newFolderURL = parentFolderURL.appendingPathComponent(newFolderName)
            } else {
                let sourceFolderURL = baseFolder.appendingPathComponent(oldPath)
                let parentFolderURL = sourceFolderURL.deletingLastPathComponent()
                newFolderURL = parentFolderURL.appendingPathComponent(newFolderName)
            }
            
            do {
                try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
                print("새 폴더 생성됨: \(newFolderURL.path)")
                
                // 새 폴더 CoreData 모델 생성
                let newFolderModel = ContentModel(cid: UUID(),
                                                  name: newFolderName,
                                                  path: FileManagerManager.shared.relativePath(for: newFolderURL.path),
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
                CoreDataManager.shared.saveContext()
                
                let children = ContentManager.shared.fetchChildrenModels(for: model.cid)
                print("자식 항목 수: \(children.count)")
                
                for child in children {
                    if child.type == .folder {
                        print("하위 폴더 복제 시작: \(child.name)")
                        duplicateContent(child, newParent: newFolderModel.cid, dashboardContents: dashboardContents)
                    } else {
                        guard let oldFilePath = child.path else { continue }
                        let sourceFileURL = baseFolder.appendingPathComponent(oldFilePath)
                        let newFileName = child.name
                        let destinationFileURL = newFolderURL.appendingPathComponent(newFileName)
                        
                        print("파일 복사 시도: \(sourceFileURL.path) -> \(destinationFileURL.path)")
                        
                        do {
                            guard FileManager.default.fileExists(atPath: sourceFileURL.path) else {
                                print("원본 파일이 존재하지 않습니다: \(sourceFileURL.path)")
                                continue
                            }
                            
                            if FileManager.default.fileExists(atPath: destinationFileURL.path) {
                                try FileManager.default.removeItem(at: destinationFileURL)
                            }
                            
                            try FileManager.default.copyItem(at: sourceFileURL, to: destinationFileURL)
                            print("파일 복사 성공: \(newFileName)")
                            
                            if let newRelativePath = FileManagerManager.shared.relativePath(for: destinationFileURL.path) {
                                ContentManager.shared.createContent(name: newFileName,
                                                                    path: newRelativePath,
                                                                    type: child.type.rawValue,
                                                                    category: child.category.rawValue,
                                                                    parent: newFolderModel.cid,
                                                                    s_dids: nil)
                                CoreDataManager.shared.saveContext()
                                print("파일 CoreData 생성 성공: \(newFileName)")
                            }
                        } catch {
                            print("파일 복제 실패: \(error)")
                        }
                    }
                }
            } catch {
                print("폴더 복제 실패: \(error)")
            }
        } else {
            let newName = (newParent == nil)
            ? generateDuplicateFileName(for: model, dashboardContents: dashboardContents)
            : model.name
            
            guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: dashboardContents),
                  let relativePath = model.path else { return }
            
            let destinationURL: URL
            if let newParent = newParent,
               let parentModel = ContentManager.shared.fetchContentModel(with: newParent),
               let parentRelativePath = parentModel.path {
                let parentFolderURL = baseFolder.appendingPathComponent(parentRelativePath)
                destinationURL = parentFolderURL.appendingPathComponent(newName)
            } else {
                let sourceURL = baseFolder.appendingPathComponent(relativePath)
                destinationURL = sourceURL.deletingLastPathComponent().appendingPathComponent(newName)
            }
            
            do {
                let sourceURL = baseFolder.appendingPathComponent(relativePath)
                guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                    print("원본 파일이 존재하지 않습니다: \(sourceURL.path)")
                    return
                }
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
                    ContentManager.shared.createContent(name: newName,
                                                        path: newRelativePath,
                                                        type: model.type.rawValue,
                                                        category: model.category.rawValue,
                                                        parent: newParent ?? model.parent,
                                                        s_dids: nil)
                    CoreDataManager.shared.saveContext()
                }
            } catch {
                print("파일 복제 실패: \(error)")
            }
        }
    }
    
    // MARK: - Delete
    func deleteContent(_ content: ContentModel) {
        // 폴더인 경우 하위 콘텐츠들을 재귀적으로 삭제
        if content.type == .folder {
            let children = ContentManager.shared.fetchChildrenModels(for: content.cid)
            for child in children {
                deleteContent(child)
            }
        }
        
        // 파일 시스템에서 실제 파일/폴더 삭제
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
        
        // CoreData 상에서 해당 콘텐츠 삭제
        ContentManager.shared.deleteContent(model: content)
    }
    
    // MARK: - Helper 함수들
    // 1. 파일 복제 시 이름 생성
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
    
    // 2. 폴더 복제 시 이름 생성
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
