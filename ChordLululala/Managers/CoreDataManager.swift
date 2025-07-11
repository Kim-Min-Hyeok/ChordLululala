//
//  CoreDataManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Core Data 저장 실패: \(error)")
        }
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
    
    // MARK: 백업 관련
    func backfillAllEntityIDs() throws {
            let model = PersistenceController.shared.container.managedObjectModel
            let ctx = self.context
            
            try model.entitiesByName.forEach { name, entity in
                // id 속성이 없거나 UUID 타입이 아니면 skip
                guard let idAttr = entity.attributesByName["id"],
                      idAttr.attributeType == .UUIDAttributeType else { return }
                
                let req = NSFetchRequest<NSManagedObject>(entityName: name)
                req.predicate = NSPredicate(format: "id == nil")
                let missing = try ctx.fetch(req)
                
                for obj in missing {
                    obj.setValue(UUID(), forKey: "id")
                }
                
                if !missing.isEmpty {
                    print("🔨 backfill: \(name) 엔티티에 \(missing.count)개 id 채움")
                }
            }
            
            if ctx.hasChanges {
                try ctx.save()
                print("✅ backfillAllEntityIDs: 저장 완료")
            }
        }
    
    var storeURLs: [URL] {
            guard let storeURL = PersistenceController
                    .shared
                    .container
                    .persistentStoreDescriptions
                    .first?
                    .url else { return [] }
            let base = storeURL.deletingPathExtension()
            return ["sqlite","sqlite-shm","sqlite-wal"]
                .map { base.appendingPathExtension($0) }
        }

        /// 이 함수만 남겨두고 JSON 관련 코드는 삭제하세요
        func backupStoreFiles(to folder: URL) throws {
            let fm = FileManager.default
            try fm.createDirectory(at: folder, withIntermediateDirectories: true)
            for src in storeURLs where fm.fileExists(atPath: src.path) {
                let dst = folder.appendingPathComponent(src.lastPathComponent)
                try fm.copyItem(at: src, to: dst)
            }
        }

    func mergeBackupStore(at sqliteURL: URL) throws {
        let coordinator = PersistenceController.shared.container.persistentStoreCoordinator
        guard let primaryStore = coordinator.persistentStores.first else {
            fatalError("✨ primary store가 없습니다.")
        }

        let secondary = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: sqliteURL,
            options: [NSReadOnlyPersistentStoreOption: true]
        )

        let mergeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mergeContext.parent = self.context

        // Attribute만 먼저 복사
        try mergeContext.performAndWait {
            let entities = coordinator.managedObjectModel.entitiesByName
            for (name, desc) in entities {
                let backups = try fetchBackupObjects(entity: name, in: mergeContext, from: secondary)
                for backup in backups {
                    importAttributes(from: backup, entityDesc: desc, in: self.context, primaryStore: primaryStore)
                }
            }
            try self.context.save()
            print("✅ Attribute 복구 완료 저장")
        }

        // Relationship 복사 (루트 제외)
        try mergeContext.performAndWait {
            let entities = coordinator.managedObjectModel.entitiesByName
            for (name, desc) in entities {
                let backups = try fetchBackupObjects(entity: name, in: mergeContext, from: secondary)
                for backup in backups {
                    guard let primary = findPrimaryObject(id: backup.value(forKey: "id") as? UUID,
                                                          entity: name,
                                                          in: self.context,
                                                          store: primaryStore) else { continue }

                    importRelationships(from: backup,
                                        to: primary,
                                        entityDesc: desc,
                                        in: self.context,
                                        primaryStore: primaryStore)
                }
            }
            try self.context.save()
            print("✅ Relationship 복구 완료 저장")
        }

        try coordinator.remove(secondary)
    }


        // MARK: - Helpers

        private func fetchBackupObjects(entity: String,
                                        in ctx: NSManagedObjectContext,
                                        from store: NSPersistentStore) throws
            -> [NSManagedObject]
        {
            let req = NSFetchRequest<NSManagedObject>(entityName: entity)
            req.returnsObjectsAsFaults = false
            req.affectedStores = [store]
            return try ctx.fetch(req)
        }

        private func findPrimaryObject(id: UUID?,
                                       entity: String,
                                       in ctx: NSManagedObjectContext,
                                       store: NSPersistentStore) -> NSManagedObject?
        {
            guard let id = id else { return nil }
            let req = NSFetchRequest<NSManagedObject>(entityName: entity)
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1
            req.affectedStores = [store]
            return try? ctx.fetch(req).first
        }

    private func importAttributes(from backup: NSManagedObject,
                                  entityDesc: NSEntityDescription,
                                  in ctx: NSManagedObjectContext,
                                  primaryStore: NSPersistentStore)
    {
        let name = entityDesc.name!
        guard let id = backup.value(forKey: "id") as? UUID else { return }

        // 루트 Content일 경우 특별 처리 (중요한 수정)
        if name == "Content", backup.value(forKey: "parentContent") == nil {
            if !updateRootID(from: backup, in: ctx, primaryStore: primaryStore) {
                // 루트가 없을 경우 새로 생성 (중요!)
                let newRoot = NSEntityDescription.insertNewObject(forEntityName: name, into: ctx)
                for (attrName, _) in entityDesc.attributesByName {
                    newRoot.setValue(backup.value(forKey: attrName), forKey: attrName)
                }
                print("⚠️ 루트 Content(\(id))가 없어서 새로 생성됨")
            }
            return
        }

        // 중복 체크
        if findPrimaryObject(id: id, entity: name, in: ctx, store: primaryStore) != nil {
            return
        }

        // 새 객체 생성 + 속성 복사
        let newObj = NSEntityDescription.insertNewObject(forEntityName: name, into: ctx)
        for (attrName, _) in entityDesc.attributesByName {
            newObj.setValue(backup.value(forKey: attrName), forKey: attrName)
        }
    }


    @discardableResult
    private func updateRootID(from backup: NSManagedObject,
                              in ctx: NSManagedObjectContext,
                              primaryStore: NSPersistentStore) -> Bool
    {
        let rootName = backup.value(forKey: "name") as? String ?? ""
        let req = NSFetchRequest<NSManagedObject>(entityName: "Content")
        req.predicate = NSPredicate(format: "parentContent == nil AND name == %@", rootName)
        req.fetchLimit = 1
        req.affectedStores = [primaryStore]
        if let root = (try? ctx.fetch(req))?.first,
           let newID = backup.value(forKey: "id") as? UUID
        {
            root.setValue(newID, forKey: "id")
            print("✅ 루트 Content(\(rootName)) ID 업데이트 완료: \(newID)")
            return true
        }
        print("⚠️ 루트 Content(\(rootName)) ID 업데이트 실패: 객체 없음")
        return false
    }
    
    private func importRelationships(from backup: NSManagedObject,
                                     to primary: NSManagedObject,
                                     entityDesc: NSEntityDescription,
                                     in ctx: NSManagedObjectContext,
                                     primaryStore: NSPersistentStore) {
        let name = entityDesc.name!

        // Content 루트 객체만 제외하고 모든 관계 복구
        if name == "Content", backup.value(forKey: "parentContent") == nil {
            return
        }

        for (relName, relDesc) in entityDesc.relationshipsByName {
            if relDesc.isToMany {
                let srcSet = backup.mutableSetValue(forKey: relName)
                let dstSet = primary.mutableSetValue(forKey: relName)
                for related in srcSet {
                    guard let relObj = related as? NSManagedObject,
                          let relID = relObj.value(forKey: "id") as? UUID,
                          let target = findPrimaryObject(id: relID,
                                                         entity: relDesc.destinationEntity!.name!,
                                                         in: ctx,
                                                         store: primaryStore) else {
                        print("❌ 관계 복구 실패(\(name).\(relName)): id=\((related as? NSManagedObject)?.value(forKey: "id") ?? "nil")")
                        continue
                    }
                    dstSet.add(target)
                }
            } else {
                guard let related = backup.value(forKey: relName) as? NSManagedObject,
                      let relID = related.value(forKey: "id") as? UUID,
                      let target = findPrimaryObject(id: relID,
                                                     entity: relDesc.destinationEntity!.name!,
                                                     in: ctx,
                                                     store: primaryStore) else {
                    print("❌ 단일 관계 복구 실패(\(name).\(relName)): related id=\((backup.value(forKey: relName) as? NSManagedObject)?.value(forKey: "id") ?? "nil")")
                    continue
                }
                primary.setValue(target, forKey: relName)
            }
        }
    }

    func validateRelationshipsBeforeBackup() {
        let ctx = self.context
        let fetchRequest = NSFetchRequest<Content>(entityName: "Content")
        
        do {
            let contents = try ctx.fetch(fetchRequest)
            for content in contents {
                if let setlist = content.setlist, setlist.id == nil {
                    print("⚠️ \(content.name ?? "")의 setlist에 id 없음")
                }
                if let scoreDetail = content.scoreDetail, scoreDetail.id == nil {
                    print("⚠️ \(content.name ?? "")의 scoreDetail에 id 없음")
                }
                if let originalParent = content.originalParent, originalParent.id == nil {
                    print("⚠️ \(content.name ?? "")의 originalParent에 id 없음")
                }
                content.setlistScores?.forEach { score in
                    if (score as? Content)?.id == nil {
                        print("⚠️ \(content.name ?? "")의 setlistScores에 id 없음")
                    }
                }
            }
        } catch {
            print("⚠️ validateRelationshipsBeforeBackup 실패: \(error)")
        }
    }

    func cleanBrokenContentRelationships() {
        let ctx = self.context
        let fetchRequest = NSFetchRequest<Content>(entityName: "Content")

        do {
            let contents = try ctx.fetch(fetchRequest)
            var cleanCount = 0

            for content in contents {
                if let setlist = content.setlist, setlist.managedObjectContext == nil {
                    content.setlist = nil
                    cleanCount += 1
                    print("⚠️ 관계 정리됨(Content.setlist): \(content.name ?? "")")
                }
                if let originalParent = content.originalParent, originalParent.managedObjectContext == nil {
                    content.originalParent = nil
                    cleanCount += 1
                    print("⚠️ 관계 정리됨(Content.originalParent): \(content.name ?? "")")
                }
                if let scoreDetail = content.scoreDetail, scoreDetail.managedObjectContext == nil {
                    content.scoreDetail = nil
                    cleanCount += 1
                    print("⚠️ 관계 정리됨(Content.scoreDetail): \(content.name ?? "")")
                }
            }

            if cleanCount > 0 {
                try ctx.save()
                print("✅ cleanBrokenContentRelationships: \(cleanCount)개 관계 정리 완료 저장")
            } else {
                print("✅ cleanBrokenContentRelationships: 정리할 관계 없음")
            }
        } catch {
            print("❌ cleanBrokenContentRelationships 실패: \(error)")
        }
    }
}
