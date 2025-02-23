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
}
