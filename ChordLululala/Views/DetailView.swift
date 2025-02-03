//
//  DetailView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import SwiftUI

// router 사용 예시 View
struct DetailView: View {
    let timestamp: String
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detail View")
                .font(.largeTitle)
            Text("Timestamp: \(timestamp)")
                .font(.title2)
            
            Button("Go Back") {
                router.back()
            }
        }
        .padding()
        .navigationTitle("Detail")
    }
}
