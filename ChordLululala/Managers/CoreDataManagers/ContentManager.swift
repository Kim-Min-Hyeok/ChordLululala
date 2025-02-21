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
    private let context = PersistenceController.shared.container.viewContext

    // Content fetch: NSPredicate로 필터링할 수 있음
    func fetchContents(predicate: NSPredicate? = nil) -> AnyPublisher<[Content], Error> {
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
    
    // 새 Content 생성 (파일/폴더)
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
        newContent.type = type            // 0: score, 1: song_list, 2: folder
        newContent.category = category    // 0: score, 1: song_list, 2: trash
        newContent.parent = parent
        newContent.createdAt = Date()
        newContent.modifiedAt = Date()
        newContent.lastAccessedAt = Date()
        newContent.deletedAt = nil
        newContent.isTrash = false
        newContent.originalParentId = nil
        newContent.syncStatus = false
        newContent.s_dids = s_dids as NSArray?
        do {
            try context.save()
        } catch {
            print("Error saving content: \(error)")
        }
    }
    
    func deleteContent(_ content: Content) {
        context.delete(content)
        do {
            try context.save()
        } catch {
            print("Error deleting content: \(error)")
        }
    }
    
    // 업데이트 등의 추가 메서드 구현 가능
    
    
    // TODO: 테스트용 모든 데이터 삭제
    func deleteAllCoreDataObjects() {
        let context = PersistenceController.shared.container.viewContext
        let entityNames = PersistenceController.shared.container.managedObjectModel.entities.map({ $0.name! })
        
        entityNames.forEach { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
}
