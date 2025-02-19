//
//  ContentView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 1/31/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // Core data context
    @Environment(\.managedObjectContext) private var viewContext
    
    // 네비게이션 라우터
    @StateObject private var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            AllDocumentView()
                .navigationDestination(for: Route.self) { route in
                    switch route.name {
                    case "/": // initial Root(HomeView): "/"
                        AllDocumentView()
                    case "/recent":
                        RecentDocumentView()
                    case "/songlist":
                        SongListView()
                    case "/trashcan":
                        TrashCanView()
                        //                    case "/score":
                        //                        ScoreView()
                    default:
                        Text("알 수 없는 경로: \(route.name)")
                    }
                }
        }
        .environmentObject(router)
    }
}
