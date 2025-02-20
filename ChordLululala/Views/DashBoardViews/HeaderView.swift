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
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.isSidebarVisible.toggle()
                }
            }) {
                Image("menu") // Assets의 menu.png 사용
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
                    .padding(.leading, 24)
            }
            Text("검색")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.leading, 10)
            TextField("검색어 입력", text: $viewModel.searchText)
                .padding(10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
            Button(action: {
                // 사용자 버튼 액션
            }) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 11)
            }
        }
        .frame(height: 53)
        .background(Color.gray)
        .clipShape(Capsule())
        .shadow(radius: 5)
    }
}
