//
//  RecentDocumentView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct RecentDocumentView: View {
    var body: some View {
        DocumentViewContainer {
            VStack {
                Text("최근 문서 내용")
                    .font(.largeTitle)
                    .padding()
                // 추가 RecentDocumentView 콘텐츠
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
