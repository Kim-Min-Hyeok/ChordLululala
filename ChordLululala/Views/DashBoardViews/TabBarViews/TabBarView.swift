//
//  TabBarView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI

struct TabBarView: View {
    var onSelect: (DashboardContents) -> Void
    @EnvironmentObject var router: NavigationRouter
    @State private var selected: DashboardContents = .allDocuments
    
    var body: some View {
        HStack(alignment: .top, spacing: 115) {
            TabBarButtonView(imageName: "score", title: "악보", action: {
                selected = .allDocuments
                onSelect(.allDocuments)
            }, isSelected: selected == .allDocuments)
            
            TabBarButtonView(imageName: "setlist", title: "셋리스트", action: {
                selected = .songList
                onSelect(.songList)
            }, isSelected: selected == .songList)
            
            TabBarButtonView(imageName: "trash", title: "휴지통", action: {
                selected = .trashCan
                onSelect(.trashCan)
            }, isSelected: selected == .trashCan)
            
            TabBarButtonView(imageName: "mypage", title: "마이페이지", action: {
                selected = .myPage
                onSelect(selected)
            }, isSelected: false)
        }
        .frame(maxWidth: .infinity, maxHeight: 110)
        .background(Color.primaryBaseWhite)
    }
}
