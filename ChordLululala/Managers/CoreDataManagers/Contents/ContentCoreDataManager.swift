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
    
    // TODO: Create
    // 모델로 Content 직접 Content 생성
    func createContent(model: ContentModel) {
        let newEntity = Content(context: context)
        newEntity.update(from: model)
        CoreDataManager.shared.saveContext()
    }
    
    // default Content 생성
    func createContent(name: String,
                       path: String? = nil,
                       type: Int16,
                       parent: UUID? = nil,
                       s_dids: [UUID]? = nil) {
        let now = Date()
        let model = ContentModel(cid: UUID(),
                                 name: name,
                                 path: path,
                                 type: ContentType(rawValue: type) ?? .score,
                                 parent: parent,
                                 createdAt: now,
                                 modifiedAt: now,
                                 lastAccessedAt: now,
                                 deletedAt: nil,
                                 originalParentId: parent,
                                 syncStatus: false,
                                 s_dids: s_dids)
        createContent(model: model)
    }
    
    // 기본 디렉토리 초기화: Score, Song_List, Trash_Can 생성
    func initializeBaseDirectories() {
        let baseDirectories = ["Score",
                               "Song_List",
                               "Trash_Can"]
        for name in baseDirectories {
            let predicate = NSPredicate(format: "name == %@ AND parent == nil", name)
            if fetchContentModelsSync(predicate: predicate).isEmpty {
                createContent(name: name,
                              path: name,
                              type: ContentType.folder.rawValue,
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
    
    func loadContentModels(forParent parent: ContentModel?, dashboardContents: DashboardContents) -> AnyPublisher<[ContentModel], Error> {
        var predicate: NSPredicate
        
        // 이미 특정 폴더(parent)가 주어졌다면 그 폴더의 자식들을 불러옴
        if let parent = parent {
            predicate = NSPredicate(format: "parent == %@", parent.cid as CVarArg)
        } else {
            // 최상위 컨텐츠 로드: dashboardContents에 따라 base 디렉토리로 분기
            switch dashboardContents {
            case .allDocuments:
                if let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score") {
                    predicate = NSPredicate(format: "parent == %@", scoreBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .recentDocuments:
                if let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score"),
                   let songListBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                    predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "parent == %@", scoreBase.cid as CVarArg),
                        NSPredicate(format: "parent == %@", songListBase.cid as CVarArg)
                    ])
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .songList:
                if let songListBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Song_List") {
                    predicate = NSPredicate(format: "parent == %@", songListBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            case .trashCan:
                if let trashBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Trash_Can") {
                    predicate = NSPredicate(format: "parent == %@", trashBase.cid as CVarArg)
                } else {
                    predicate = NSPredicate(value: false)
                }
            }
        }
        
        // 최근 문서인 경우 최근 1일 내 접근한 콘텐츠 필터링
        if dashboardContents == .recentDocuments {
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let recentPredicate = NSPredicate(format: "lastAccessedAt >= %@", oneDayAgo as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, recentPredicate])
        }
        
        return ContentCoreDataManager.shared.fetchContentModelsPublisher(predicate: predicate)
    }
    
    // MARK: Update
    // 현재 변경 사항 저장
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
    
    // 휴지통 이동
    func moveContentToTrash(_ model: inout ContentModel) {
        model.modifiedAt = Date()
        model.lastAccessedAt = Date()
        model.deletedAt = Date()
        
        if let trashBase = fetchBaseDirectory(named: "Trash_Can") {
            model.parent = trashBase.cid
        }
        
        updateContent(model: model)
    }
    
    // MARK: Delete
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
}
