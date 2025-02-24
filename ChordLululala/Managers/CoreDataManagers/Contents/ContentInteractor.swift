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
                                                parent: currentParent?.id,
                                                s_dids: nil)
        }
    }
    
    // 폴더 생성
    func createFolder(folderName: String, currentParent: ContentModel?, dashboardContents: DashboardContents) {
        guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: dashboardContents) else { return }
        let parentRelativePath = currentParent?.path ?? ""
        let relativeFolderPath = parentRelativePath.isEmpty ? folderName : (parentRelativePath as NSString).appendingPathComponent(folderName)
        if let newFolderURL = FileManagerManager.shared.createSubfolderIfNeeded(for: relativeFolderPath, inBaseFolder: baseFolder),
           let newRelativePath = FileManagerManager.shared.relativePath(for: newFolderURL.path) {
            ContentManager.shared.createContent(name: folderName,
                                                path: newRelativePath,
                                                type: ContentType.folder.rawValue,
                                                category: ContentCategory.score.rawValue,
                                                parent: currentParent?.id,
                                                s_dids: nil)
        }
    }
    
    // MARK: - Read
    func loadContentModels(forParent parent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<[ContentModel], Error> {
        var predicate: NSPredicate
        if let parentID = parent?.id {
            predicate = NSPredicate(format: "parent == %@", parentID as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        
        switch dashboardContents {
        case .allDocuments:
            let trashPredicate = NSPredicate(format: "isTrash == NO")
            let typePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "type == %d", ContentType.score.rawValue),
                NSPredicate(format: "type == %d", ContentType.folder.rawValue)
            ])
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate, typePredicate])
            
        case .recentDocuments:
            let trashPredicate = NSPredicate(format: "isTrash == NO")
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let recentPredicate = NSPredicate(format: "lastAccessedAt >= %@", oneDayAgo as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate, recentPredicate])
            
        case .songList:
            let typePredicate = NSPredicate(format: "type == %d", ContentType.songList.rawValue)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, typePredicate])
            
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
        
        if isFile, let oldPath = updatedModel.path,
           let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let oldURL = docsURL.appendingPathComponent(oldPath)
            let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(updatedName)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    updatedModel.path = newRelativePath
                }
            } catch {
                print("파일 이름 변경 실패: \(error)")
            }
        }
        
        // ContentManager의 updateContent 메서드 호출 (NSFetchRequest 제거)
        ContentManager.shared.updateContent(model: updatedModel)
    }
    
    // 2. 휴지통 이동
    func moveContentToTrash(_ model: ContentModel) {
        var updatedModel = model
        updatedModel.isTrash = true
        updatedModel.modifiedAt = Date()
        updatedModel.lastAccessedAt = Date()
        
        // 파일만 처리
        guard updatedModel.type != .folder,
              let oldPath = updatedModel.path,
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let trashURL = FileManagerManager.shared.documentsURL?.appendingPathComponent("Trash_Can", isDirectory: true)
        else { return }
        
        let oldURL = docsURL.appendingPathComponent(oldPath)
        guard FileManager.default.fileExists(atPath: oldURL.path) else {
            print("원본 파일이 존재하지 않습니다: \(oldURL.path)")
            return
        }
        
        if !FileManager.default.fileExists(atPath: trashURL.path) {
            do {
                try FileManager.default.createDirectory(at: trashURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Trash_Can 폴더 생성 실패: \(error)")
                return
            }
        }
        
        let newURL = trashURL.appendingPathComponent(oldURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                updatedModel.path = newRelativePath
            }
        } catch {
            print("파일 휴지통 이동 실패: \(error)")
        }
        
        // ContentManager의 업데이트 메서드 사용
        ContentManager.shared.updateContent(model: updatedModel)
    }
    
    // MARK: - 복제 (파일은 복제, 폴더는 재귀 복제)
    func duplicateContent(_ model: ContentModel, newParent: UUID? = nil, dashboardContents: DashboardContents) {
        if model.type == .folder {
            let targetParent = newParent ?? model.parentID
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
                let newFolderModel = ContentModel(id: UUID(),
                                                  name: newFolderName,
                                                  path: FileManagerManager.shared.relativePath(for: newFolderURL.path),
                                                  type: .folder,
                                                  category: model.category,
                                                  parentID: targetParent,
                                                  createdAt: Date(),
                                                  modifiedAt: Date(),
                                                  lastAccessedAt: Date(),
                                                  deletedAt: nil,
                                                  isTrash: false,
                                                  originalParentId: nil,
                                                  syncStatus: false,
                                                  s_dids: nil)
                ContentManager.shared.createContent(model: newFolderModel)
                CoreDataManager.shared.saveContext()
                
                let children = ContentManager.shared.fetchChildrenModels(for: model.id)
                print("자식 항목 수: \(children.count)")
                
                for child in children {
                    if child.type == .folder {
                        print("하위 폴더 복제 시작: \(child.name)")
                        duplicateContent(child, newParent: newFolderModel.id, dashboardContents: dashboardContents)
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
                                                                    type: ContentType.score.rawValue,
                                                                    category: child.category.rawValue,
                                                                    parent: newFolderModel.id,
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
                                                        type: ContentType.score.rawValue,
                                                        category: model.category.rawValue,
                                                        parent: newParent ?? model.parentID,
                                                        s_dids: nil)
                    CoreDataManager.shared.saveContext()
                }
            } catch {
                print("파일 복제 실패: \(error)")
            }
        }
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
        let siblings = ContentManager.shared.fetchChildrenModels(for: model.parentID)
        while siblings.contains(where: { $0.name == newName }) {
            index += 1
            newName = "\(baseName) (\(index))"
        }
        return newName
    }
}
