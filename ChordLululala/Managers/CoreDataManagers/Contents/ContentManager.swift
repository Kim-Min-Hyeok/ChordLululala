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

    // 여러 Contents (비동기: Combine)
    func fetchContentsPublisher(predicate: NSPredicate? = nil) -> AnyPublisher<[Content], Error> {
        Future { promise in
            let request: NSFetchRequest<Content> = Content.fetchRequest()
            request.predicate = predicate
            do {
                let contents = try self.context.fetch(request)
                promise(.success(contents))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 여러 Contents (동기)
    func fetchContentsSync(predicate: NSPredicate? = nil) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = predicate
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching contents: \(error)")
            return []
        }
    }
    
    // Content 가져오기 (by predicate)
    func fetchContent(predicate: NSPredicate) -> Content? {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = predicate
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching content: \(error)")
            return nil
        }
    }
    
    // Content 가져오기 (by id)
    func fetchContent(with id: UUID) -> Content? {
        let predicate = NSPredicate(format: "cid == %@", id as CVarArg)
        return fetchContent(predicate: predicate)
    }
    
    // Content 가져오기 (by name, parent)
    func fetchContent(named name: String, parent: UUID?) -> Content? {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "name == %@ AND parent == %@", name, parent as CVarArg)
        } else {
            predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
        }
        return fetchContent(predicate: predicate)
    }
    
    // 자식 Content들 가져오기 (by parent)
    func fetchChildren(for parent: UUID?) -> [Content] {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "parent == %@", parent as CVarArg)
        } else {
            predicate = NSPredicate(format: "parent == nil")
        }
        return fetchContentsSync(predicate: predicate)
    }
    
    // Content 생성
    func createContent(name: String,
                       path: String? = nil,
                       type: Int16,
                       category: Int16,
                       parent: UUID? = nil,
                       s_dids: [UUID]? = nil) {
        let newContent = Content(context: context)
        newContent.cid = UUID()
        newContent.name = name
        newContent.path = path
        newContent.type = type
        newContent.category = category
        newContent.parent = parent
        newContent.createdAt = Date()
        newContent.modifiedAt = Date()
        newContent.lastAccessedAt = Date()
        newContent.deletedAt = nil
        newContent.isTrash = false
        newContent.originalParentId = nil
        newContent.syncStatus = false
        newContent.s_dids = s_dids as NSArray?
        CoreDataManager.shared.saveContext()
    }
    
    // 기본 디렉토리 초기화: Score, Song_List, Trash_Can
    func initializeBaseDirectories() {
        let baseDirectories = [("Score", Int16(0)), ("Song_List", Int16(1)), ("Trash_Can", Int16(2))]
        for (name, category) in baseDirectories {
            let predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
            if fetchContentsSync(predicate: predicate).isEmpty {
                createContent(name: name, path: name, type: 2, category: category, parent: nil, s_dids: nil)
                print("\(name) base directory created.")
            }
        }
    }
    
    // 기본 디렉토리 Content(Score, Song_List, Trash_Can) 가져오기
    func fetchBaseDirectory(named name: String) -> Content? {
        let predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
        return fetchContent(predicate: predicate)
    }
    
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
