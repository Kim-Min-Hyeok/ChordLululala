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
            TextField("검색", text: $viewModel.searchText)
                .padding(10)
                .clipped()
                .cornerRadius(16)
                .foregroundColor(.black)
                .frame(height: 53)
                .background(Color.gray)
            
            // MARK: 전체/파일/폴더
            FileFolderFilterToggleView(selectedFilter: $viewModel.currentFilter)
                .padding(.horizontal, 249)
                .padding(.top, 33)
        }
    }
}
