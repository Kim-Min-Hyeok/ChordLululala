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
    @Binding var selected: DashboardContents
    
    var body: some View {
        HStack(alignment: .top, spacing: 115) {
            TabBarButtonView(imageName: "score", title: "악보", action: {
                selected = .score
                onSelect(.score)
            }, isSelected: selected == .score)
            
            TabBarButtonView(imageName: "setlist", title: "셋리스트", action: {
                selected = .setlist
                onSelect(.setlist)
            }, isSelected: selected == .setlist)
            
            TabBarButtonView(imageName: "mypage", title: "내 계정", action: {
                selected = .myPage
                onSelect(selected)
            }, isSelected: selected == .myPage || selected == .trashCan)
        }
        .frame(maxWidth: .infinity, maxHeight: 110)
        .background(Color.primaryBaseWhite)
    }
}
