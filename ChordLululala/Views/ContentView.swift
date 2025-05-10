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
            DashboardView()
                .navigationDestination(for: Route.self) { route in
                    switch route.name {
                    case "/": // initial Root(HomeView): "/"
                        DashboardView()
                    case "/login":
                        LoginView()
                    case "/termsofservice":
                        TermsOfServiceView()
                    case "/score":
                        if let content = route.arguments as? [ContentModel],
                           let first = content.first{
                                ScoreView(content: first)
                            } else {
                                Text("❌ ContentModel 전달 실패: \(String(describing: route.arguments))")
                            }
                    case "/chordreconize":
                        if let args = route.arguments as? [ContentModel],
                               let file = args.first {
                                ChordReconizeView(file: file)
                                    .environmentObject(router)
                            } else {
                                Text("❌ ContentModel 전달 실패: \(String(describing: route.arguments))")
                            }
                    default:
                        Text("알 수 없는 경로: \(route.name)")
                    }
                }
        }
        .environmentObject(router)
        .onAppear {
            if let _ = UserDefaults.standard.string(forKey: "lastLoggedInUserID") {
                router.offAll("/")
            } else {
                router.offAll("/login")
            }
        }
    }
}
