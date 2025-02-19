//
//  AllDocumentView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct AllDocumentView: View {
    var body: some View {
        DocumentViewContainer {
            VStack {
                Text("모든 문서 내용")
                    .font(.largeTitle)
                    .padding()
                // 추가 AllDocumentView 콘텐츠
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
