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
    func uploadFile(
        with url: URL,
        currentParent: ContentModel?,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<ContentModel?, Never> {
        // 1) Future를 명시적으로 변수에 담아 타입을 분명히 함
        let future: Future<ContentModel?, Never> = Future { promise in
            let rel = currentParent?.path
            ContentFileManagerManager.shared.uploadFile(
                from: url,
                to: dashboardContents,
                relativeFolderPath: rel
            ) { result in
                switch result {
                case .success((let destURL, let relPath)):
                    // CoreData에 저장하고, 생성된 모델을 리턴
                    let model = ContentCoreDataManager.shared.createContent(
                        name: destURL.lastPathComponent,
                        path: relPath,
                        type: ContentType.score.rawValue,
                        parent: currentParent,
                        scoreDetail: nil
                    )
                    promise(.success(model))
                case .failure(let err):
                    print("파일 업로드 실패:", err)
                    promise(.success(nil))
                }
            }
        }
        
        // 2) 명시적으로 eraseToAnyPublisher() 호출
        return future
            .eraseToAnyPublisher()
    }
    
    // 셋리스트 생성
    func createSetlist(
        named name: String,
        with originalScores: [ContentModel],
        currentParent: ContentModel?,
        dashboardContents: DashboardContents
    ) -> AnyPublisher<ContentModel, Never> {
        Future<ContentModel, Never> { promise in
            let now = Date()

            // 1. Setlist 생성
            let setlist = ContentModel(
                cid: UUID(),
                name: name,
                path: nil,
                type: .setlist,
                parentContent: currentParent,
                createdAt: now,
                modifiedAt: now,
                lastAccessedAt: now,
                deletedAt: nil,
                originalParentId: currentParent?.cid,
                syncStatus: false,
                isStared: false,
                scoreDetail: nil,
                scores: []
            )

            // 2. CoreData에 Setlist 저장
            let savedSetlist = ContentCoreDataManager.shared.createContent(model: setlist)

            // 3. Setlist.scores에 score 복사본 추가 (parentContent는 nil 처리)
            for score in originalScores {
                let clonedScore = ContentModel(
                    cid: UUID(),
                    name: score.name,
                    path: score.path,
                    type: .scoresOfSetlist,
                    parentContent: nil,
                    createdAt: now,
                    modifiedAt: now,
                    lastAccessedAt: now,
                    deletedAt: nil,
                    originalParentId: nil,
                    syncStatus: false,
                    isStared: false,
                    scoreDetail: nil,
                    scores: nil
                )

                // CoreData 저장
                let saved = ContentCoreDataManager.shared.createContent(model: clonedScore)

                // Setlist 내부 연결 (메모리 상)
                savedSetlist.scores?.append(saved)
            }

            // 4. 결과 리턴
            promise(.success(savedSetlist))
        }
        .eraseToAnyPublisher()
    }
    
    // 폴더 생성
    func createFolder(folderName: String,
                      currentParent: ContentModel?,
                      dashboardContents: DashboardContents) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            guard let currentParent = currentParent else {
                promise(.success(()))
                return
            }
            if dashboardContents == .setlist {
                ContentCoreDataManager.shared.createContent(
                    name: folderName,
                    path: nil,                      // 파일 시스템 경로 없음
                    type: ContentType.folder.rawValue,
                    parent: currentParent,
                    scoreDetail: nil
                )
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
                                                                parent: currentParent,
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
            let updatedModel = model
            let fileExtension = (model.name as NSString).pathExtension
            let isFile = updatedModel.type == .score

            let updatedName = isFile && !fileExtension.isEmpty
                ? newName + "." + fileExtension
                : newName

            updatedModel.name = updatedName
            updatedModel.modifiedAt = Date()
            updatedModel.lastAccessedAt = Date()

            if model.type == .setlist {
                ContentCoreDataManager.shared.updateContent(model: updatedModel)
                promise(.success(()))
                return
            }

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
                    updated.parentContent = destination
                    updated.originalParentId = destination.cid
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
            
            if updatedModel.type == .setlist {
                ContentCoreDataManager.shared.updateContent(model: updatedModel)
                promise(.success(()))
                return
            }
            
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
            // 원본 부모 모델을 미리 가져온다
            guard let originalParentId = content.originalParentId,
                  let originalParentContent = ContentCoreDataManager.shared.fetchContentModel(with: originalParentId),
                  let parentFolderRelativePath = originalParentContent.path,
                  !parentFolderRelativePath.isEmpty else {
                print("복구할 원본 부모 정보 또는 경로가 없습니다.")
                promise(.success(()))
                return
            }

            // 1. 도메인 모델 업데이트
            content.deletedAt = nil
            content.parentContent = originalParentContent
            content.originalParentId = nil

            // 2. 셋리스트 타입이면 CoreData만 업데이트하고 종료
            if content.type == .setlist {
                ContentCoreDataManager.shared.updateContent(model: content)
                promise(.success(()))
                return
            }

            // 3. 현재 Content의 파일 경로가 필요함
            guard let currentRelativePath = content.path,
                  !currentRelativePath.isEmpty,
                  let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("현재 Content의 파일 경로가 없습니다.")
                promise(.success(()))
                return
            }

            let sourceURL = docsURL.appendingPathComponent(currentRelativePath)
            let destinationFolderURL = docsURL.appendingPathComponent(parentFolderRelativePath)
            let fileName = (currentRelativePath as NSString).lastPathComponent
            let destinationURL = destinationFolderURL.appendingPathComponent(fileName)

            // 4. 물리적 파일 이동
            ContentFileManagerManager.shared.moveItem(from: sourceURL, to: destinationURL) { result in
                switch result {
                case .success(let newRelativePath):
                    content.path = newRelativePath
                    ContentCoreDataManager.shared.updateContent(model: content)
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
    func duplicateContent(
            _ model: ContentModel,
            newParent: ContentModel? = nil,
            dashboardContents: DashboardContents
        ) -> AnyPublisher<ContentModel, Never> {
            switch model.type {
            case .score, .scoresOfSetlist:
                return duplicateScore(model, newParent: newParent, dashboardContents: dashboardContents)
            case .folder:
                return duplicateFolder(model, newParent: newParent, dashboardContents: dashboardContents)
            case .setlist:
                return duplicateSetlist(model, newParent: newParent, dashboardContents: dashboardContents)
            }
        }

        private func duplicateScore(
            _ model: ContentModel,
            newParent: ContentModel? = nil,
            dashboardContents: DashboardContents
        ) -> AnyPublisher<ContentModel, Never> {
            Future { promise in
                let newCID = UUID()
                let parentModel = newParent ?? model.parentContent
                let newName = newParent == nil ? ContentNamer.shared.generateDuplicateFileName(for: model, dashboardContents: dashboardContents) : model.name

                guard let oldPath = model.path else {
                            promise(.success(model))
                            return
                        }

                let parentRel = parentModel?.path


                switch ContentFileManagerManager.shared.duplicateFile(
                    oldFilePath: oldPath,
                    newFileName: newName,
                    newParentRelativePath: parentRel,
                    dashboardContents: dashboardContents
                ) {
                case .success(let destURL):
                    guard let newRel = FileManagerManager.shared.relativePath(for: destURL.path) else {
                        promise(.success(model))
                        return
                    }

                    let newModel = ContentModel(
                        cid: newCID,
                        name: newName,
                        path: newRel,
                        type: model.type,
                        parentContent: parentModel,
                        createdAt: model.modifiedAt,
                        modifiedAt: model.modifiedAt,
                        lastAccessedAt: model.modifiedAt,
                        deletedAt: nil,
                        originalParentId: parentModel?.cid,
                        syncStatus: false,
                        isStared: false,
                        scoreDetail: nil,
                        scores: []
                    )

                    let created = ContentCoreDataManager.shared.createContent(model: newModel)
                    promise(.success(created))

                case .failure:
                    promise(.success(model))
                }
            }.eraseToAnyPublisher()
        }

        private func duplicateFolder(
            _ model: ContentModel,
            newParent: ContentModel? = nil,
            dashboardContents: DashboardContents
        ) -> AnyPublisher<ContentModel, Never> {
            Future { promise in
                let newCID = UUID()
                let parentModel = newParent ?? model.parentContent
                let newName = newParent == nil ? ContentNamer.shared.generateDuplicateFolderAndSetlistName(for: model) : model.name

                guard let oldPath = model.path else {
                            promise(.success(model))
                            return
                        }

                let parentRel = parentModel?.path

                switch ContentFileManagerManager.shared.duplicateFolder(
                    oldFolderPath: oldPath,
                    newFolderName: newName,
                    newParentRelativePath: parentRel,
                    dashboardContents: dashboardContents
                ) {
                case .success(let newURL):
                    guard let newRel = FileManagerManager.shared.relativePath(for: newURL.path) else {
                        promise(.success(model))
                        return
                    }

                    let newModel = ContentModel(
                        cid: newCID,
                        name: newName,
                        path: newRel,
                        type: .folder,
                        parentContent: parentModel,
                        createdAt: model.modifiedAt,
                        modifiedAt: model.modifiedAt,
                        lastAccessedAt: model.modifiedAt,
                        deletedAt: nil,
                        originalParentId: newParent?.cid,
                        syncStatus: false,
                        isStared: false,
                        scoreDetail: nil,
                        scores: []
                    )

                    let created = ContentCoreDataManager.shared.createContent(model: newModel)
                    let children = ContentCoreDataManager.shared.fetchChildrenModels(for: model.cid)

                    children.forEach { child in
                        _ = duplicateContent(child, newParent: created, dashboardContents: dashboardContents)
                            .sink { _ in }
                    }

                    promise(.success(created))

                case .failure:
                    promise(.success(model))
                }
            }.eraseToAnyPublisher()
        }

        private func duplicateSetlist(
            _ model: ContentModel,
            newParent: ContentModel? = nil,
            dashboardContents: DashboardContents
        ) -> AnyPublisher<ContentModel, Never> {
            Future { promise in
                let newCID = UUID()
                let parentModel = newParent ?? model.parentContent
                let newName = newParent == nil ? ContentNamer.shared.generateDuplicateFolderAndSetlistName(for: model) : model.name

                let newModel = ContentModel(
                    cid: newCID,
                    name: newName,
                    path: nil,
                    type: .setlist,
                    parentContent: parentModel,
                    createdAt: model.modifiedAt,
                    modifiedAt: model.modifiedAt,
                    lastAccessedAt: model.modifiedAt,
                    deletedAt: nil,
                    originalParentId: newParent?.cid,
                    syncStatus: false,
                    isStared: false,
                    scoreDetail: nil,
                    scores: []
                )

                let created = ContentCoreDataManager.shared.createContent(model: newModel)

                        guard let originalScores = model.scores else {
                            promise(.success(created))
                            return
                        }

                        let cloneTasks = originalScores.map { score in
                            self.duplicateScore(score, newParent: created, dashboardContents: dashboardContents)
                        }

                _ = Publishers.MergeMany(cloneTasks)
                            .collect()
                            .sink { clonedScores in
                                created.scores = clonedScores
                                promise(.success(created))
                            }
                    }
                    .eraseToAnyPublisher()
        }
    
    // 삭제 – 작업 완료 시 Void 발행
    func deleteContent(_ content: ContentModel) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            // 1) setlist 타입은 파일 시스템에 기록이 없으므로 CoreData만 삭제
            if content.type == .setlist {
                ContentCoreDataManager.shared.deleteContent(model: content)
                promise(.success(()))
                return
            }

            // 2) 그 외(score, folder)은 물리 파일/폴더 삭제
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

            // 3) Core Data에서도 삭제 (Cascade Delete가 설정되어 있으면 자식 항목도 함께 삭제)
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
