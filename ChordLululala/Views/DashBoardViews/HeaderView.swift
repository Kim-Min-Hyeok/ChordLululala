//
//  HeaderView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("검색", text: $viewModel.searchText)
                    .foregroundColor(.black)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemGray6))  // 옅은 회색 배경
            .cornerRadius(10)
            .frame(height: 53)
            
            // MARK: 전체/파일/폴더
            AllStarFilterToggleView(selectedFilter: $viewModel.currentFilter)
                .padding(.horizontal, 249)
                .padding(.top, 33)
        }
    }
}
