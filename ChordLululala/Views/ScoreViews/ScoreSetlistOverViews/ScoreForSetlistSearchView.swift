//
//  ScoreForSetlistSearchView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/17/25.
//

import SwiftUI

struct ScoreForSetlistSearchView: View {
    @ObservedObject var viewModel: ScoreSetlistOverViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.primaryGray500)
                    .frame(width: 25, height: 25)
                
                TextField(
                    "",
                    text: $viewModel.searchText,
                    prompt: Text("파일명 검색").foregroundColor(Color.primaryGray500)
                )
                .textStyle(.headingLgRegular)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .focused($isFocused)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.primaryGray200)
            .cornerRadius(10)
            .frame(height: 46)
        }
    }
}
