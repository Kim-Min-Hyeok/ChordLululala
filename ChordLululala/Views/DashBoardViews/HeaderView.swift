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
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.primaryGray500)
                    .frame(width: 25, height: 25)
                
                TextField("", text: $viewModel.searchText, prompt: Text("검색").foregroundColor(Color.primaryGray500))
                    .textStyle(.headingLgRegular)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 11)
            .background(Color.primaryGray200)
            .cornerRadius(10)
            .frame(height: 46)
            
            HStack {

                // MARK: 전체/즐겨찾기
                AllStarFilterToggleView(selectedFilter: $viewModel.currentFilter)
                    .padding(.leading, 293)

                HStack(spacing: 7) {
                    // MARK: 선택 버튼
                    Button(action: {
                        withAnimation {
                            viewModel.isSelectionViewVisible = true
                        }
                    }) {
                        Image("select")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    .padding(.leading, 171)

                    // MARK: 리스트/그리드 토글 버튼
                    Button(action: {
                        viewModel.isListView.toggle()
                    }) {
                        Image(viewModel.isListView ? "list" : "not_list")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.top, 44)
        }
    }
}
