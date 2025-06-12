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
    @discardableResult
    func createContent(
        name: String,
        path: String? = nil,
        type: Int16,
        parent: Content? = nil
    ) -> Content {
        let now = Date()
        let entity = Content(context: context)
        entity.name           = name
        entity.path           = path
        entity.type           = type
        entity.createdAt      = now
        entity.modifiedAt     = now
        entity.lastAccessedAt = now
        entity.deletedAt      = nil
        entity.isStared       = false
        entity.syncStatus     = false
        entity.parentContent  = parent
        // originalParent 관계는 moveToTrash 시에 설정
        
        do {
            try context.save()
        } catch {
            print("❌ createContent error:", error)
        }
        return entity
    }
    
    func initializeBaseDirectories() {
        let baseNames = ["Score", "Setlist", "Trash_Can"]
        
        // 1) 한 번에존재 여부 조회
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "name IN %@ AND parentContent == nil", baseNames)
        do {
            let existing = try context.fetch(request).compactMap { $0.name }
            let missing = baseNames.filter { !existing.contains($0) }
            
            // 2) 없는 것만 생성
            for name in missing {
                let entity = Content(context: context)
                entity.name = name
                entity.path = name
                entity.type = ContentType.folder.rawValue
                entity.createdAt = Date()
                entity.modifiedAt = Date()
                entity.lastAccessedAt = Date()
                entity.deletedAt = nil
                entity.isStared = false
                entity.syncStatus = false
                // parentContent는 nil
                print("✅ \(name) base directory created.")
            }
            
            // 3) 한 번에 저장
            try context.save()
        } catch {
            print("❌ initializeBaseDirectories 오류: \(error)")
        }
    }
    
    // MARK: - Read
    // Fetch (비동기)
    func fetchContentsPublisher(
        predicate: NSPredicate? = nil
    ) -> AnyPublisher<[Content], Error> {
        Future { promise in
            let request: NSFetchRequest<Content> = Content.fetchRequest()
            request.predicate = predicate
            do {
                let results = try self.context.fetch(request)
                promise(.success(results))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Fetch (동기)
    func fetchContentsSync(predicate: NSPredicate? = nil) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = predicate
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching Content entities: \(error)")
            return []
        }
    }
    
    func fetchChildrenSync(for parent: Content?) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        if let p = parent {
            request.predicate = NSPredicate(format: "parentContent == %@", p)
        } else {
            request.predicate = NSPredicate(format: "parentContent == nil")
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching children for \(String(describing: parent)): \(error)")
            return []
        }
    }
    
    func fetchScoresFromSetlist(_ setlist: Content) -> [Content] {
        let children = (setlist.setlistScores as? Set<Content>) ?? []
        return Array(children)
    }
    
    // 기본 디렉토리 Content(Score, Setlist_List, Trash_Can) 가져오기
    func fetchBaseDirectory(named name: String) -> Content? {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND parentContent == nil", name)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching base directory '\(name)': \(error)")
            return nil
        }
    }
    
    // MARK: - Update
    
    func moveEntity(
        _ entity: Content,
        to newParent: Content,
        newRelativePath: String? = nil
    ) {
        entity.parentContent = newParent
        // 원본 부모 저장해 두면, 복구 때 쓸 수 있습니다.
        if entity.originalParent == nil {
            entity.originalParent = entity.originalParent ?? entity.parentContent
        }
        if let newRel = newRelativePath {
            entity.path = newRel
        }
        // 타임스탬프 갱신
        entity.modifiedAt     = Date()
        entity.lastAccessedAt = Date()
        saveContext()
    }
    
    func moveContentToTrash(entity: Content) {
        // 타임스탬프 업데이트
        entity.modifiedAt     = Date()
        entity.lastAccessedAt = Date()
        entity.deletedAt      = Date()
        
        // originalParent 관계로 저장해 두었다가 복구에 사용
        entity.originalParent = entity.originalParent ?? entity.parentContent
        
        // parentContent 를 Trash_Can으로 변경
        if let trash = fetchBaseDirectory(named: "Trash_Can") {
            entity.parentContent = trash
        }
    }
    
    func restoreContent(entity: Content) {
        // 삭제 플래그 해제
        entity.deletedAt = nil
        
        // parentContent를 originalParent로 되돌리기
        if let orig = entity.originalParent {
            entity.parentContent   = orig
        } else {
            // originalParent가 없으면 최상위로
            entity.parentContent = nil
        }
        
        // originalParent 관계 해제
        entity.originalParent = nil
        
        // 타임스탬프 복원
        entity.modifiedAt     = Date()
        entity.lastAccessedAt = Date()
    }
    
    // MARK: - Delete
    func deleteContent(_ content: Content) {
        context.delete(content)
        saveContext()
        print("Core Data에서 삭제 성공: \(content.name ?? "Unnamed")")
    }
    
    // MARK: 즐겨찾기 토글
    func toggleContentStared(content: Content) {
        content.isStared.toggle()
        content.modifiedAt = Date()
        saveContext()
        print("즐겨찾기 토글: \(content.name ?? "Unnamed") → \(content.isStared ? "★" : "☆")")
    }
    
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}
