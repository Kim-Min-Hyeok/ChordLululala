//
//  ContentCoreDataManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Foundation
import CoreData
import Combine

final class ContentCoreDataManager {
    static let shared = ContentCoreDataManager()
    private let context = CoreDataManager.shared.context
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Create
    
    // 모델로 Content 직접 생성 (부모 관계를 실제 엔티티로 연결)
    func createContent(model: ContentModel) {
        let newEntity = Content(context: context)
        newEntity.update(from: model)
        
        // 부모 UUID가 있다면, 해당하는 Content 엔티티를 찾아서 관계 설정
        if let parentID = model.parentContent {
            let parentRequest: NSFetchRequest<Content> = Content.fetchRequest()
            parentRequest.predicate = NSPredicate(format: "cid == %@", parentID as CVarArg)
            if let parentEntity = try? context.fetch(parentRequest).first {
                newEntity.parentContent = parentEntity
            } else {
                newEntity.parentContent = nil
            }
        } else {
            newEntity.parentContent = nil
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    // 기본 Content 생성 (UUID를 부모로 전달)
    func createContent(name: String,
                       path: String? = nil,
                       type: Int16,
                       parent: UUID? = nil,
                       scoreDetail: UUID? = nil) {
        let now = Date()
        let model = ContentModel(cid: UUID(),
                                 name: name,
                                 path: path,
                                 type: ContentType(rawValue: type) ?? .score,
                                 parentContent: parent,
                                 createdAt: now,
                                 modifiedAt: now,
                                 lastAccessedAt: now,
                                 deletedAt: nil,
                                 originalParentId: parent,
                                 syncStatus: false,
                                 isStared: false,
                                 scoreDetail: scoreDetail)
        createContent(model: model)
    }
    
    // 기본 디렉토리 초기화: Score, Song_List, Trash_Can 생성
    func initializeBaseDirectories() {
        let baseDirectories = ["Score",
                               "Song_List",
                               "Trash_Can"]
        for name in baseDirectories {
            let predicate = NSPredicate(format: "name == %@ AND parentContent == nil", name)
            if fetchContentModelsSync(predicate: predicate).isEmpty {
                createContent(name: name,
                              path: name,
                              type: ContentType.folder.rawValue,
                              parent: nil,
                              scoreDetail: nil)
                print("\(name) base directory created.")
            }
        }
    }
    
    // MARK: - Read
    // Fetch (비동기: 도메인 모델 반환)
    func fetchContentModelsPublisher(predicate: NSPredicate? = nil) -> AnyPublisher<[ContentModel], Error> {
        Future { promise in
            let request: NSFetchRequest<Content> = Content.fetchRequest()
            request.predicate = predicate
            do {
                let entities = try self.context.fetch(request)
                let models = entities.map { ContentModel(entity: $0) }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Fetch (동기: 도메인 모델 반환)
    func fetchContentModelsSync(predicate: NSPredicate? = nil) -> [ContentModel] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = predicate
        do {
            let entities = try context.fetch(request)
            return entities.map { ContentModel(entity: $0) }
        } catch {
            print("Error fetching contents: \(error)")
            return []
        }
    }
    
    // 특정 Content 도메인 모델 가져오기 (by predicate)
    func fetchContentModel(predicate: NSPredicate) -> ContentModel? {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = predicate
        do {
            if let entity = try context.fetch(request).first {
                return ContentModel(entity: entity)
            }
        } catch {
            print("Error fetching content: \(error)")
        }
        return nil
    }
    
    // Content 도메인 모델 가져오기 (by id)
    func fetchContentModel(with id: UUID) -> ContentModel? {
        let predicate = NSPredicate(format: "cid == %@", id as CVarArg)
        return fetchContentModel(predicate: predicate)
    }
    
    // Content 도메인 모델 가져오기 (by name, parent)
    func fetchContentModel(named name: String, parentId: UUID?) -> ContentModel? {
        let predicate: NSPredicate
        if let parentId = parentId {
            predicate = NSPredicate(format: "name == %@ AND parentContent.cid == %@", name, parentId as CVarArg)
        } else {
            predicate = NSPredicate(format: "name == %@ AND parentContent.cid == nil", name)
        }
        return fetchContentModel(predicate: predicate)
    }
    
    // 자식 Content 도메인 모델들 가져오기 (by parentId(cid))
    func fetchChildrenModels(for parentId: UUID?) -> [ContentModel] {
        let predicate: NSPredicate
        if let parentId = parentId {
            predicate = NSPredicate(format: "parentContent.cid == %@", parentId as CVarArg)
        } else {
            predicate = NSPredicate(format: "parentContent.cid == nil")
        }
        return fetchContentModelsSync(predicate: predicate)
    }
    
    // 기본 디렉토리 Content(Score, Song_List, Trash_Can) 가져오기
    func fetchBaseDirectory(named name: String) -> ContentModel? {
        let predicate = NSPredicate(format: "name == %@ AND parentContent == nil", name)
        return fetchContentModel(predicate: predicate)
    }
    
    func loadContentModels(forParent parent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<[ContentModel], Error> {
        var predicate: NSPredicate
        
        // 이미 특정 폴더(parent)가 주어졌다면 그 폴더의 자식들을 불러옴
        if let parent = parent {
            predicate = NSPredicate(format: "parentContent.cid == %@", parent.cid as CVarArg)
        } else {
            // 최상위 컨텐츠 로드: dashboardContents에 따라 base 디렉토리로 분기
            switch dashboardContents {
            case .allDocuments:
                if let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                    predicate = NSPredicate(format: "parentContent.cid == %@", scoreBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .songList:
                if let songListBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                    predicate = NSPredicate(format: "parentContent.cid == %@", songListBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .trashCan:
                if let trashBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                    predicate = NSPredicate(format: "parentContent.cid == %@", trashBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .myPage:
                predicate = NSPredicate(value: false)
            }
        }
        
        return ContentCoreDataManager.shared.fetchContentModelsPublisher(predicate: predicate)
    }
    
    // MARK: - Update
    // 현재 변경 사항 저장 (부모 관계도 업데이트)
    func updateContent(model: ContentModel) {
        let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cid == %@", model.cid as CVarArg)
        do {
            if let coreEntity = try context.fetch(fetchRequest).first {
                coreEntity.update(from: model)
                
                // 부모 관계 업데이트
                if let parentID = model.parentContent {
                    let parentRequest: NSFetchRequest<Content> = Content.fetchRequest()
                    parentRequest.predicate = NSPredicate(format: "cid == %@", parentID as CVarArg)
                    if let parentEntity = try? context.fetch(parentRequest).first {
                        coreEntity.parentContent = parentEntity
                    } else {
                        coreEntity.parentContent = nil
                    }
                } else {
                    coreEntity.parentContent = nil
                }
                
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Failed to update content: \(error)")
        }
    }
    
    // 휴지통 이동
    func moveContentToTrash(_ model: inout ContentModel) {
        model.modifiedAt = Date()
        model.lastAccessedAt = Date()
        model.deletedAt = Date()
        
        if let trashBase = fetchBaseDirectory(named: "Trash_Can") {
            model.parentContent = trashBase.cid
        }
        
        updateContent(model: model)
    }
    
    // MARK: - Delete
    func deleteContent(model: ContentModel) {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "cid == %@", model.cid as CVarArg)
        do {
            if let entityToDelete = try context.fetch(request).first {
                context.delete(entityToDelete)
                CoreDataManager.shared.saveContext()
                print("Content 삭제 성공: \(model.name)")
            } else {
                print("삭제할 Content를 찾을 수 없음: \(model.name)")
            }
        } catch {
            print("Content 삭제 실패: \(error)")
        }
    }
    
    // MARK: 즐겨찾기 토글
    func toggleContentStared(model: ContentModel) {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "cid == %@", model.cid as CVarArg)
        
        do {
            if let entityToUpdate = try context.fetch(request).first {
                entityToUpdate.isStared.toggle()
                entityToUpdate.modifiedAt = Date() // 수정 시각 업데이트
                CoreDataManager.shared.saveContext()
                print("즐겨찾기 토글 완료: \(entityToUpdate.name ?? "Unnamed") → \(entityToUpdate.isStared ? "★" : "☆")")
            } else {
                print("즐겨찾기 토글 실패: 해당 콘텐츠를 찾을 수 없음 (\(model.name))")
            }
        } catch {
            print("즐겨찾기 토글 중 오류 발생: \(error)")
        }
    }
}
