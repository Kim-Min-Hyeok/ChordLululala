//
//  HeaderView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: DocumentViewModel
    @State private var searchText: String = ""
    
    var body: some View {
        HStack {
            // 햄버거 버튼: 사이드바 토글
            Button(action: {
                withAnimation {
                    viewModel.isSidebarVisible.toggle()
                }
            }) {
                Image("menu") // Assets에 추가한 menu.png
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
            
            TextField("검색어 입력", text: $searchText)
                .padding(10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
            
            Button(action: {
                // 사용자 버튼 액션 (추후 구현)
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
