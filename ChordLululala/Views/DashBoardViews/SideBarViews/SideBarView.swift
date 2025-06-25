//
//  SideBarView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SidebarView: View {
    var onSelect: (DashboardContents) -> Void
    @EnvironmentObject var router: NavigationRouter
    @Binding var selected: DashboardContents
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Noteflow")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(Color.primaryBlue600)
                .padding(EdgeInsets(top: 20.1, leading: 25, bottom: 17.9, trailing: 0))
            
            SidebarButtonView(imageName: "score", title: "악보", action: {
                selected = .score
                onSelect(selected)
            }, isSelected: selected == .score)
            
            SidebarButtonView(imageName: "setlist", title: "셋리스트", action: {
                selected = .setlist
                onSelect(selected)
            }, isSelected: selected == .setlist)
            
            SidebarButtonView(imageName: "mypage", title: "내 계정", action: {
                selected = .myPage
                onSelect(selected)
            }, isSelected: selected == .myPage || selected == .trashCan)
            
            Spacer()
        }
        .frame(maxWidth: 257, maxHeight: .infinity, alignment: .leading)
        .background(Color.primaryBaseWhite)
    }
}
