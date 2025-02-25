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
}
