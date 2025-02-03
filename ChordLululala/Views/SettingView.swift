//
//  SettingView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Setting")
                .font(.largeTitle)
            Button("Back to Home") {
                router.back()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Setting")
    }
}

#Preview {
    SettingView()
}
