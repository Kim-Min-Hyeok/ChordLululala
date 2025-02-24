//
//  ChordLululalaApp.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 1/31/25.
//

import SwiftUI

@main
struct ChordLululalaApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            //            ContentView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            //                .preferredColorScheme(.light)
            ScoreView()
                .preferredColorScheme(.light)
        }
    }
}
