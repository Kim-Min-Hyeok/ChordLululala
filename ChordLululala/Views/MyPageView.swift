//
//  MyPageView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("My Page")
                .font(.largeTitle)
            Button("Back to Home") {
                router.back()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("My Page")
    }
}
