//
//  Persistence.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 1/31/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ChordLululala")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if (error as NSError?) != nil {

            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
