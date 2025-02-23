import Foundation
import Combine
import SwiftUI

final class ContentInteractor {
    static let shared = ContentInteractor()
    private var cancellables = Set<AnyCancellable>()
    
    
    
    // MARK: Create
    // 1. 파일 생성
    func uploadFile(with url: URL, currentParent: Content?, selectedContent: DashboardContent) {
        let baseFolder = FileManagerManager.shared.baseFolderURL(for: selectedContent)
        let relativeFolderPath = currentParent?.path
        if let destinationURL = FileManagerManager.shared.copyPDFToBaseFolder(from: url,
                                                                              relativeFolderPath: relativeFolderPath,
                                                                              baseFolder: baseFolder),
           let relativePath = FileManagerManager.shared.relativePath(for: destinationURL.path) {
            ContentManager.shared.createContent(name: destinationURL.lastPathComponent,
                                                path: relativePath,
                                                type: 0,
                                                category: 0,
                                                parent: currentParent?.cid,
                                                s_dids: nil)
        }
    }
    
    // 2. 폴더 생성
    func createFolder(folderName: String, currentParent: Content?, selectedContent: DashboardContent) {
        let baseFolder = FileManagerManager.shared.baseFolderURL(for: selectedContent)
        let parentRelativePath = currentParent?.path ?? ""
        let relativeFolderPath = parentRelativePath.isEmpty ? folderName : (parentRelativePath as NSString).appendingPathComponent(folderName)
        if let newFolderURL = FileManagerManager.shared.createSubfolderIfNeeded(for: relativeFolderPath, inBaseFolder: baseFolder),
           let newRelativePath = FileManagerManager.shared.relativePath(for: newFolderURL.path) {
            ContentManager.shared.createContent(name: folderName,
                                                path: newRelativePath,
                                                type: 2,
                                                category: 0,
                                                parent: currentParent?.cid,
                                                s_dids: nil)
        }
    }
    
    // MARK: Read
    func loadContents(forParent parent: Content?, selectedContent: DashboardContent) -> AnyPublisher<[Content], Error> {
        var predicate: NSPredicate
        if let parentID = parent?.cid {
            predicate = NSPredicate(format: "parent == %@", parentID as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        
        switch selectedContent {
        case .trashCan:
            let trashPredicate = NSPredicate(format: "isTrash == YES")
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, trashPredicate])
        case .recentDocuments:
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let recentPredicate = NSPredicate(format: "modifiedAt >= %@", oneDayAgo as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, recentPredicate])
        default:
            break
        }
        
        return ContentManager.shared.fetchContentsPublisher(predicate: predicate)
    }
    
    // MARK: Update
    // 1. 이름 수정
    func renameContent(_ content: Content, newName: String) {
        let isFile = content.type != 2
        let updatedName = isFile ? newName + ".pdf" : newName
        content.name = updatedName
        content.modifiedAt = Date()
        if isFile, let oldPath = content.path,
           let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let oldURL = docsURL.appendingPathComponent(oldPath)
            let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(updatedName)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    content.path = newRelativePath
                }
            } catch {
                print("파일 이름 변경 실패: \(error)")
            }
        }
        CoreDataManager.shared.saveContext()
    }
    
    // 2. 경로 수정 (-> 휴지통)
    func moveContentToTrash(_ content: Content) {
        content.isTrash = true
        content.modifiedAt = Date()
        if content.type != 2, let oldPath = content.path,
           let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let trashURL = FileManagerManager.shared.documentsURL?.appendingPathComponent("Trash_Can", isDirectory: true) {
            let oldURL = docsURL.appendingPathComponent(oldPath)
            let newURL = trashURL.appendingPathComponent(oldURL.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newURL.path) {
                    content.path = newRelativePath
                }
            } catch {
                print("파일 휴지통 이동 실패: \(error)")
            }
        }
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: 복제 (파일이면 복제, 폴더이면 재귀 복제)
    // - 최상위 호출(newParent == nil)일 경우, 새 이름을 생성하여 복제된 폴더는 원본 폴더와 같은 parent에 생성
    func duplicateContent(_ content: Content, newParent: UUID? = nil, selectedContent: DashboardContent) {
        if content.type == 2 {  // 폴더 복제
            let targetParent = newParent ?? content.parent
            let newFolderName = (newParent == nil)
                ? generateDuplicateFolderName(for: content)
                : (content.name ?? "Unnamed")
            
            guard let baseFolder = FileManagerManager.shared.baseFolderURL(for: selectedContent),
                  let oldPath = content.path else { return }
            
            // 새 대상 폴더 URL 계산
            let newFolderURL: URL
            if let newParent = newParent,
               let newParentContent = ContentManager.shared.fetchContent(with: newParent),
               let parentRelativePath = newParentContent.path {
                let parentFolderURL = baseFolder.appendingPathComponent(parentRelativePath)
                newFolderURL = parentFolderURL.appendingPathComponent(newFolderName)
            } else {
                let sourceFolderURL = baseFolder.appendingPathComponent(oldPath)
                let parentFolderURL = sourceFolderURL.deletingLastPathComponent()
                newFolderURL = parentFolderURL.appendingPathComponent(newFolderName)
            }
            
            do {
                // 1. 새 폴더 생성
                try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
                print("새 폴더 생성됨: \(newFolderURL.path)")
                
                var newFolder: Content?
                if let newRelativePath = FileManagerManager.shared.relativePath(for: newFolderURL.path) {
                    ContentManager.shared.createContent(name: newFolderName,
                                                        path: newRelativePath,
                                                        type: 2,
                                                        category: content.category,
                                                        parent: targetParent,
                                                        s_dids: nil)
                    CoreDataManager.shared.saveContext()
                    
                    // 동기적으로 새 폴더 객체를 가져옴 (폴더 검색은 unified fetchContent 사용)
                    newFolder = ContentManager.shared.fetchContent(named: newFolderName, parent: targetParent)
                    print("새 폴더 CoreData 생성됨: \(newFolderName)")
                }
                
                // 2. 하위 항목 복제 (자식은 fetchContentsSync 사용)
                if let cid = content.cid {
                    let children = ContentManager.shared.fetchContentsSync(predicate: NSPredicate(format: "parent == %@", cid as CVarArg))
                    print("자식 항목 수: \(children.count)")
                    
                    for child in children {
                        if child.type == 2 {  // 폴더인 경우 재귀 복제
                            print("하위 폴더 복제 시작: \(child.name ?? "")")
                            duplicateContent(child, newParent: newFolder?.cid, selectedContent: selectedContent)
                        } else {  // 파일 복제
                            guard let oldFilePath = child.path else { continue }
                            let sourceFileURL = baseFolder.appendingPathComponent(oldFilePath)
                            let newFileName = child.name ?? "Unnamed"
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
                                                                        type: 0,
                                                                        category: child.category,
                                                                        parent: newFolder?.cid,
                                                                        s_dids: nil)
                                    CoreDataManager.shared.saveContext()
                                    print("파일 CoreData 생성 성공: \(newFileName)")
                                }
                            } catch {
                                print("파일 복제 실패: \(error)")
                            }
                        }
                    }
                }
                
            } catch {
                print("폴더 복제 실패: \(error)")
            }
            
        } else {  // 파일 복제
            let newName = (newParent == nil)
                ? generateDuplicateFileName(for: content, selectedContent: selectedContent)
                : (content.name ?? "Unnamed")
            
            if let baseFolder = FileManagerManager.shared.baseFolderURL(for: selectedContent),
               let relativePath = content.path {
                let destinationURL: URL
                if let newParent = newParent,
                   let newParentContent = ContentManager.shared.fetchContent(with: newParent),
                   let parentRelativePath = newParentContent.path {
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
                                                            type: 0,
                                                            category: content.category,
                                                            parent: newParent ?? content.parent,
                                                            s_dids: nil)
                        CoreDataManager.shared.saveContext()
                    }
                } catch {
                    print("파일 복제 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: Helper 함수들
    // 1. 복제 시 파일명
    private func generateDuplicateFileName(for content: Content, selectedContent: DashboardContent) -> String {
        guard content.type != 2, let originalName = content.name else { return "Unnamed.pdf" }
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        var index = 1
        var newName = "\(baseName) (\(index)).\(ext)"
        if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let oldPath = content.path {
            let originalFileURL = docsURL.appendingPathComponent(oldPath)
            let parentDirectory = originalFileURL.deletingLastPathComponent()
            while FileManager.default.fileExists(atPath: parentDirectory.appendingPathComponent(newName).path) {
                index += 1
                newName = "\(baseName) (\(index)).\(ext)"
            }
        }
        return newName
    }
    
    // 2. 복제시 폴더 명
    private func generateDuplicateFolderName(for content: Content) -> String {
        let baseName = content.name ?? "Unnamed"
        var index = 1
        var newName = "\(baseName) (\(index))"
        let siblings = ContentManager.shared.fetchContentsSync(predicate: NSPredicate(format: "parent == %@", (content.parent ?? UUID()) as CVarArg))
        while siblings.contains(where: { $0.name == newName }) {
            index += 1
            newName = "\(baseName) (\(index))"
        }
        return newName
    }
}
