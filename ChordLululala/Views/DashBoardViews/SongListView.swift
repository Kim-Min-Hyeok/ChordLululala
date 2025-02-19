//
//  SongListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SongListView: View {
    var body: some View {
        DocumentViewContainer {
            VStack {
                Text("곡 목록 내용")
                    .font(.largeTitle)
                    .padding()
                // 추가 SongListView 콘텐츠
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
