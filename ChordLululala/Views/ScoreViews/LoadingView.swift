//
//  LoadingView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/5/25.
//

import SwiftUI

/// 로딩뷰
struct LoadingView: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 28){
            Text("악보와 조(key)를 인식하고 있어요.")
                .textStyle(.headingMdSemiBold)
            CustomCircularProgressView()
        }
        
    }
}

