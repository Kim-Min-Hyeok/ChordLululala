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
    
    func initializeBaseDirectories() {
        ContentCoreDataManager.shared.initializeBaseDirectories()
    }
    
    func fetchBaseDirectory(named name: String) -> Content? {
        return ContentCoreDataManager.shared.fetchBaseDirectory(named: name)
    }
    
    func loadContents(
        forParent parent: Content?,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<[Content], Error> {
        // 1) predicate 생성
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "parentContent == %@", parent)
        } else {
            switch dashboardContents {
            case .score:
                if let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                    predicate = NSPredicate(format: "parentContent == %@", scoreBase)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .setlist:
                if let listBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                    predicate = NSPredicate(format: "parentContent == %@", listBase)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .trashCan:
                if let trashBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                    predicate = NSPredicate(format: "parentContent == %@", trashBase)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .createSetlist, .myPage:
                predicate = NSPredicate(value: false)
            }
        }
        
        // 2) CoreDataManager의 새 퍼블리셔 호출
        return ContentCoreDataManager.shared
            .fetchContentsPublisher(predicate: predicate)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // 파일 업로드 – 작업 완료 시 Void 발행
    func createScore(
        with url: URL,
        currentParent: Content,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<Content?, Never> {
        Future<Content?, Never> { promise in
            let relPath = currentParent.path
            ContentFileManagerManager.shared.uploadFile(
                from: url,
                to: dashboardContents,
                relativeFolderPath: relPath
            ) { result in
                switch result {
                case .success(let (destURL, newRelPath)):
                    // CoreData에 바로 생성
                    let newEntity = ContentCoreDataManager.shared.createContent(
                        name: destURL.lastPathComponent,
                        path: newRelPath,
                        type: ContentType.score.rawValue,
                        parent: currentParent
                    )
                    promise(.success(newEntity))
                case .failure(let err):
                    print("파일 업로드 실패:", err)
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 셋리스트 생성
    func createSetlist(
            named name: String,
            with originalScores: [Content],
            currentParent: Content?
        ) -> AnyPublisher<Content, Never> {
            Future<Content, Never> { promise in
                let now = Date()
                // 1) 셋리스트 엔티티 생성
                let setlistEntity = ContentCoreDataManager.shared.createContent(
                    name: name,
                    path: nil,
                    type: ContentType.setlist.rawValue,
                    parent: currentParent
                )
                setlistEntity.createdAt      = now
                setlistEntity.modifiedAt     = now
                setlistEntity.lastAccessedAt = now

                // 2) originalScores 각각을 scoresOfSetlist 타입으로 “연결” 복제
                let scoreEntities: [Content] = originalScores.map { orig in
                    let cloned = ContentCoreDataManager.shared.createContent(
                        name: orig.name ?? "",
                        path: orig.path,
                        type: ContentType.scoresOfSetlist.rawValue,
                        parent: nil
                    )
                    cloned.createdAt      = now
                    cloned.modifiedAt     = now
                    cloned.lastAccessedAt = now
                    // 연관 관계 설정
                    cloned.setlist = setlistEntity
                    return cloned
                }
                setlistEntity.setlistScores = NSSet(array: scoreEntities)

                // 3) Context 저장
                CoreDataManager.shared.saveContext()

                promise(.success(setlistEntity))
            }
            .eraseToAnyPublisher()
        }
    
    // 폴더 생성
    func createFolder(
        named folderName: String,
        in parent: Content,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            if dashboardContents == .setlist {
                _ = ContentCoreDataManager.shared.createContent(
                    name: folderName,
                    path: nil,
                    type: ContentType.folder.rawValue,
                    parent: parent
                )
                return promise(.success(()))
            }
            
            ContentFileManagerManager.shared.createFolder(
                named: folderName,
                relativeTo: parent,
                dashboardContents: dashboardContents
            ) { result in
                switch result {
                case .success(let (folderURL, relPath)):
                    _ = ContentCoreDataManager.shared.createContent(
                        name: folderName,
                        path: relPath,
                        type: ContentType.folder.rawValue,
                        parent: parent
                    )
                case .failure(let error):
                    print("폴더 생성 실패:", error)
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 이름 수정 – 작업 완료 시 Void 발행
    func renameContent(
        _ entity: Content,
        newName: String
    ) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) 파일 확장자 보존
            let oldName = entity.name
            let fileExt = (oldName as NSString? ?? "").pathExtension
            let isFile = entity.type == ContentType.score.rawValue
            
            let updatedName: String = {
                guard isFile, !fileExt.isEmpty else { return newName }
                return newName + "." + fileExt
            }()
            
            // 2) 엔티티 속성 갱신
            entity.name           = updatedName
            entity.modifiedAt     = Date()
            entity.lastAccessedAt = Date()
            
            // 3) 파일이면 물리 경로도 리네임
            if isFile,
               let oldRel = entity.path,
               let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let oldURL = docsURL.appendingPathComponent(oldRel)
                let newURL = oldURL
                    .deletingLastPathComponent()
                    .appendingPathComponent(updatedName)
                
                ContentFileManagerManager.shared.renameItem(at: oldURL, to: newURL) { result in
                    if case .success(let newRel) = result {
                        entity.path = newRel
                    } else if case .failure(let err) = result {
                        print("파일 이름 변경 실패:", err)
                    }
                    // 4) Core Data 저장
                    CoreDataManager.shared.saveContext()
                    promise(.success(()))
                }
            } else {
                // 폴더거나 파일 시스템 작업이 필요 없을 때
                CoreDataManager.shared.saveContext()
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 파일 이동
    func moveContent(
        _ entity: Content,
        to destination: Content
    ) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) 파일 시스템 경로(oldRel) 가져오기
            guard
                let oldRel = entity.path,
                let docsURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first
            else {
                // path가 없으면 Core Data만 업데이트
                ContentCoreDataManager.shared.moveEntity(entity, to: destination)
                return promise(.success(()))
            }
            
            let sourceURL = docsURL.appendingPathComponent(oldRel)
            let destFolder = docsURL.appendingPathComponent(destination.path ?? "", isDirectory: true)
            let newURL     = destFolder.appendingPathComponent(entity.name ?? "")
            
            // 2) 파일 시스템 이동
            ContentFileManagerManager.shared.moveItem(from: sourceURL, to: newURL) { result in
                switch result {
                case .success(let newRel):
                    // 3) Core Data 업데이트: path, parentContent, timestamps
                    ContentCoreDataManager.shared.moveEntity(
                        entity,
                        to: destination,
                        newRelativePath: newRel
                    )
                case .failure(let error):
                    print("파일 이동 실패:", error)
                    // 실패해도 Core Data 관계만 업데이트할지 결정할 수 있음
                    ContentCoreDataManager.shared.moveEntity(entity, to: destination)
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 휴지통 이동 – 작업 완료 시 Void 발행
    func moveContentToTrash(
        _ entity: Content,
        performPhysicalMove: Bool = true
    ) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) Core Data 상의 관계/타임스탬프 업데이트
            ContentCoreDataManager.shared.moveContentToTrash(entity: entity)
            
            // 2) setlist 타입(파일 시스템 기록 없음)인 경우
            if entity.type == ContentType.setlist.rawValue {
                CoreDataManager.shared.saveContext()
                return promise(.success(()))
            }
            
            // 3) 파일 시스템 실제 이동
            guard
                performPhysicalMove,
                let oldRel = entity.path,
                let docsURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first,
                let trashURL = ContentFileManagerManager.shared.trashURL()
            else {
                CoreDataManager.shared.saveContext()
                return promise(.success(()))
            }
            
            // 3a) Trash_Can 폴더 생성
            if !FileManager.default.fileExists(atPath: trashURL.path) {
                try? FileManager.default.createDirectory(
                    at: trashURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
            
            let sourceURL = docsURL.appendingPathComponent(oldRel)
            let destinationURL = trashURL.appendingPathComponent(sourceURL.lastPathComponent)
            
            do {
                // 덮어쓰기 방지
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                // 상대 경로 갱신
                if let newRel = ContentFileManagerManager.shared.relativePath(for: destinationURL.path) {
                    entity.path = newRel
                }
            } catch {
                print("파일 시스템 휴지통 이동 실패:", error)
            }
            
            // 4) 최종 Core Data 저장
            CoreDataManager.shared.saveContext()
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    // 복구
    func restoreContent(_ entity: Content) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) Core Data 상에서 관계·타임스탬프 복원
            ContentCoreDataManager.shared.restoreContent(entity: entity)
            
            // 2) setlist 타입은 물리 파일이 없으니 바로 종료
            if entity.type == ContentType.setlist.rawValue {
                CoreDataManager.shared.saveContext()
                return promise(.success(()))
            }
            
            // 3) 파일 시스템에서 Trash_Can → 원래 부모 폴더로 이동
            guard
                let oldRel = entity.path,
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let originalParent = entity.originalParent,                     // restoreContent 내에서 originalParent nil 처리 전이라면
                let parentRel = originalParent.path
            else {
                CoreDataManager.shared.saveContext()
                return promise(.success(()))
            }
            
            let trashURL = docsURL.appendingPathComponent("Trash_Can", isDirectory: true)
            let sourceURL = trashURL.appendingPathComponent((oldRel as NSString).lastPathComponent)
            let destFolderURL = docsURL.appendingPathComponent(parentRel, isDirectory: true)
            let destURL = destFolderURL.appendingPathComponent(sourceURL.lastPathComponent)
            
            ContentFileManagerManager.shared.moveItem(from: sourceURL, to: destURL) { result in
                switch result {
                case .success(let newRel):
                    entity.path = newRel
                case .failure(let err):
                    print("파일 복구 실패:", err)
                }
                // 4) 최종 Core Data 저장
                CoreDataManager.shared.saveContext()
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 복제 – 작업 완료 시 Void 발행
    func duplicateContent(
        _ entity: Content,
        newParent: Content? = nil,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<Content, Never> {
        Future<Content, Never> { promise in
            let parent = newParent ?? entity.parentContent
            let baseName = entity.name ?? ""
            let newName = "Copy of \(baseName)"
            
            switch ContentType(rawValue: entity.type) {
            case .score, .scoresOfSetlist:
                guard
                    let oldRel = entity.path,
                    let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                else {
                    return promise(.success(entity))
                }
                // synchronous duplicateFile -> Result<URL,Error>
                let result = ContentFileManagerManager.shared.duplicateFile(
                    oldFilePath: oldRel,
                    newFileName: newName,
                    newParentRelativePath: parent?.path,
                    dashboardContents: dashboardContents
                )
                switch result {
                case .success(let destURL):
                    let newRel = FileManagerManager.shared.relativePath(for: destURL.path) ?? ""
                    let clone = ContentCoreDataManager.shared.createContent(
                        name: newName,
                        path: newRel,
                        type: entity.type,
                        parent: parent
                    )
                    promise(.success(clone))
                case .failure:
                    promise(.success(entity))
                }

            case .folder:
                guard let oldRel = entity.path else {
                    return promise(.success(entity))
                }
                let result = ContentFileManagerManager.shared.duplicateFolder(
                    oldFolderPath: oldRel,
                    newFolderName: newName,
                    newParentRelativePath: parent?.path,
                    dashboardContents: dashboardContents
                )
                switch result {
                case .success(let newURL):
                    let newRel = FileManagerManager.shared.relativePath(for: newURL.path) ?? ""
                    let clone = ContentCoreDataManager.shared.createContent(
                        name: newName,
                        path: newRel,
                        type: ContentType.folder.rawValue,
                        parent: parent
                    )
                    promise(.success(clone))
                case .failure:
                    promise(.success(entity))
                }

            case .setlist:
                // setlist only Core Data
                let clone = ContentCoreDataManager.shared.createContent(
                    name: newName,
                    path: nil,
                    type: ContentType.setlist.rawValue,
                    parent: parent
                )
                promise(.success(clone))

            default:
                promise(.success(entity))
            }
        }
        .eraseToAnyPublisher()
    }

    
    // 삭제 – 작업 완료 시 Void 발행
    func deleteContent(_ content: Content) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) setlist 타입은 파일 시스템 기록이 없음 → 바로 Core Data 삭제
            if content.type == ContentType.setlist.rawValue {
                ContentCoreDataManager.shared.deleteContent(content)
                return promise(.success(()))
            }
            
            // 2) 물리 파일 또는 폴더 삭제
            if let relPath = content.path,
               let docsURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first {
                let itemURL = docsURL.appendingPathComponent(relPath)
                if FileManager.default.fileExists(atPath: itemURL.path) {
                    do {
                        try FileManager.default.removeItem(at: itemURL)
                        print("파일 시스템에서 삭제 성공: \(itemURL.path)")
                    } catch {
                        print("파일 시스템 삭제 실패:", error)
                    }
                } else {
                    print("삭제할 파일/폴더가 없습니다: \(itemURL.path)")
                }
            }
            
            // 3) Core Data 레코드 삭제 (Cascade 규칙에 따라 자식도 함께)
            ContentCoreDataManager.shared.deleteContent(content)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    // 셋리스트의 Contents 가져오기 (sync)
    func fetchScoresFromSetlist(_ setlist: Content) -> [Content] {
        return ContentCoreDataManager.shared.fetchScoresFromSetlist(setlist)
    }
    
    func toggleContentStared(_ content: Content) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            ContentCoreDataManager.shared.toggleContentStared(content: content)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
