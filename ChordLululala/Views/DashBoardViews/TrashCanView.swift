//
//  TrashCanView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct TrashCanView: View {
    var body: some View {
        DocumentViewContainer {
            VStack {
                Text("휴지통 내용")
                    .font(.largeTitle)
                    .padding()
                // 추가 TrashCanView 콘텐츠
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
