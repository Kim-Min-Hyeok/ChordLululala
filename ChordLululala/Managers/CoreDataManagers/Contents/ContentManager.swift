//
//  ContentManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import Foundation
import CoreData
import Combine

final class ContentManager {
    static let shared = ContentManager()
    private let context = CoreDataManager.shared.context
    
    // MARK: - Create
    func createContent(model: ContentModel) {
        let newEntity = Content(context: context)
        newEntity.update(from: model)
        CoreDataManager.shared.saveContext()
    }
    
    // 편의용 Create 메서드
    func createContent(name: String,
                       path: String? = nil,
                       type: Int16,
                       category: Int16,
                       parent: UUID? = nil,
                       s_dids: [UUID]? = nil) {
        let now = Date()
        let model = ContentModel(cid: UUID(),
                                 name: name,
                                 path: path,
                                 type: ContentType(rawValue: type) ?? .score,
                                 category: ContentCategory(rawValue: category) ?? .score,
                                 parent: parent,
                                 createdAt: now,
                                 modifiedAt: now,
                                 lastAccessedAt: now,
                                 deletedAt: nil,
                                 isTrash: false,
                                 originalParentId: parent,
                                 syncStatus: false,
                                 s_dids: s_dids)
        createContent(model: model)
    }
    
    // 기본 디렉토리 초기화: Score, Song_List, Trash_Can
    func initializeBaseDirectories() {
        let baseDirectories = [("Score", ContentCategory.score.rawValue),
                               ("Song_List", ContentCategory.songList.rawValue),
                               ("Trash_Can", ContentCategory.trash.rawValue)]
        for (name, category) in baseDirectories {
            let predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
            if fetchContentModelsSync(predicate: predicate).isEmpty {
                createContent(name: name,
                              path: name,
                              type: ContentType.folder.rawValue,
                              category: category,
                              parent: nil,
                              s_dids: nil)
                print("\(name) base directory created.")
            }
        }
    }
    
    // MARK: Read
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
    func fetchContentModel(named name: String, parent: UUID?) -> ContentModel? {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "name == %@ AND parent == %@", name, parent as CVarArg)
        } else {
            predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
        }
        return fetchContentModel(predicate: predicate)
    }
    
    // 자식 Content 도메인 모델들 가져오기 (by parent)
    func fetchChildrenModels(for parent: UUID?) -> [ContentModel] {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "parent == %@", parent as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        return fetchContentModelsSync(predicate: predicate)
    }
    
    // 기본 디렉토리 Content(Score, Song_List, Trash_Can) 가져오기
    func fetchBaseDirectory(named name: String) -> ContentModel? {
        let predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
        return fetchContentModel(predicate: predicate)
    }
    
    // MARK: Update
    func updateContent(model: ContentModel) {
        let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cid == %@", model.cid as CVarArg)
        do {
            if let coreEntity = try context.fetch(fetchRequest).first {
                coreEntity.update(from: model)
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Failed to update content: \(error)")
        }
    }
    
    // MARK: Delete
    // 모든 Core Data 객체 삭제 (테스트용)
    func deleteAllCoreDataObjects() {
        let entityNames = PersistenceController.shared.container.managedObjectModel.entities.map { $0.name! }
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
        CoreDataManager.shared.saveContext()
    }
}
