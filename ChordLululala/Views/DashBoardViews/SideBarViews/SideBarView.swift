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
    @State private var selected: DashboardContents = .score
    
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
            
            SidebarButtonView(imageName: "trash", title: "휴지통", action: {
                selected = .trashCan
                onSelect(selected)
            }, isSelected: selected == .trashCan)
            
            SidebarButtonView(imageName: "mypage", title: "마이페이지", action: {
                selected = .myPage
                onSelect(selected)
            }, isSelected: false)
            
            SidebarButtonView(imageName: "mypage", title: "로그아웃", action: {
                logout()
            }, isSelected: false)
            
            SidebarButtonView(imageName: "mypage", title: "데이터 초기화", action: {
                CoreDataManager.shared.deleteAllCoreDataObjects()
            }, isSelected: false)
            
            Spacer()
        }
        .frame(maxWidth: 257, maxHeight: .infinity, alignment: .leading)
        .background(Color.primaryBaseWhite)
    }
    
    private func logout() {
        // lastLoggedInUserID 삭제
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUserID")
        // /login 경로로 라우팅
        router.toNamed("/login")
    }
}
