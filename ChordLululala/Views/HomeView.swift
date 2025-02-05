//
//  HomeView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle)
                .padding()
            
            Button("Go to Score List") {
                router.toNamed("/scorelist")
            }
            .buttonStyle(.borderedProminent)
            
            Button("Go to My Page") {
                router.toNamed("/mypage")
            }
            .buttonStyle(.bordered)
            Button("Go to Setting") {
                router.toNamed("/setting")
            }
            .buttonStyle(.bordered)
        }
    }
}
