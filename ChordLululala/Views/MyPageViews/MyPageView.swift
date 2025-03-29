//
//  MyPageView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/29/25.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    
    var body: some View {
        VStack {
            Text("마이페이지")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
