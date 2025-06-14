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
    let context = PersistenceController.shared.container.viewContext
    
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

            // 1) secondary store 추가
            let secondary = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: sqliteURL,
                options: [NSReadOnlyPersistentStoreOption: true]
            )

            let mergeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            mergeContext.parent = self.context

            // 2) 1차: Attribute만 복사 (루트 id 업데이트 포함)
            try mergeContext.performAndWait {
                let entities = coordinator.managedObjectModel.entitiesByName
                for (name, desc) in entities {
                    let backups = try fetchBackupObjects(entity: name, in: mergeContext, from: secondary)
                    for backup in backups {
                        importAttributes(from: backup,
                                         entityDesc: desc,
                                         in: self.context,
                                         primaryStore: primaryStore)
                    }
                }
                try self.context.save()
            }

            // 3) 2차: Relationship 복사 (루트는 건너뜀)
            try mergeContext.performAndWait {
                let entities = coordinator.managedObjectModel.entitiesByName
                for (name, desc) in entities {
                    let backups = try fetchBackupObjects(entity: name, in: mergeContext, from: secondary)
                    for backup in backups {
                        guard let primary = findPrimaryObject(id: backup.value(forKey: "id") as? UUID,
                                                              entity: name,
                                                              in: self.context,
                                                              store: primaryStore)
                        else { continue }

                        importRelationships(from: backup,
                                            to: primary,
                                            entityDesc: desc,
                                            in: self.context,
                                            primaryStore: primaryStore)
                    }
                }
                try self.context.save()
            }

            // 4) secondary store 제거
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
            // id 확인
            guard let id = backup.value(forKey: "id") as? UUID else { return }

            // 루트(Content) 특별 처리
            if name == "Content",
               backup.value(forKey: "parentContent") == nil
            {
                updateRootID(from: backup, in: ctx, primaryStore: primaryStore)
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

        private func updateRootID(from backup: NSManagedObject,
                                  in ctx: NSManagedObjectContext,
                                  primaryStore: NSPersistentStore)
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
            }
        }

        private func importRelationships(from backup: NSManagedObject,
                                         to primary: NSManagedObject,
                                         entityDesc: NSEntityDescription,
                                         in ctx: NSManagedObjectContext,
                                         primaryStore: NSPersistentStore)
        {
            let name = entityDesc.name!
            // 루트 관계는 건너뜀
            if name == "Content",
               backup.value(forKey: "parentContent") == nil
            {
                return
            }

            for (relName, relDesc) in entityDesc.relationshipsByName {
                if relDesc.isToMany {
                    let srcSet = backup.mutableSetValue(forKey: relName)
                    let dstSet = primary.mutableSetValue(forKey: relName)
                    for related in srcSet {
                        if let relID = (related as? NSManagedObject)?.value(forKey: "id") as? UUID,
                           let target = findPrimaryObject(id: relID,
                                                          entity: relDesc.destinationEntity!.name!,
                                                          in: ctx,
                                                          store: primaryStore)
                        {
                            dstSet.add(target)
                        }
                    }
                } else {
                    if let related = backup.value(forKey: relName) as? NSManagedObject,
                       let relID = related.value(forKey: "id") as? UUID,
                       let target = findPrimaryObject(id: relID,
                                                      entity: relDesc.destinationEntity!.name!,
                                                      in: ctx,
                                                      store: primaryStore)
                    {
                        primary.setValue(target, forKey: relName)
                    }
                }
            }
        }
}
