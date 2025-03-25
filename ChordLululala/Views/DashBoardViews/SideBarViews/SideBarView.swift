//
//  SideBarView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

import SwiftUI

struct SidebarView: View {
    var onSelect: (DashboardContents) -> Void
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Noteflow")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .padding(EdgeInsets(top: 20.1, leading: 25, bottom: 17.9, trailing: 0))
            
            SidebarButtonView(imageName: "score", title: "악보") {
                onSelect(.allDocuments)
            }
            
            SidebarButtonView(imageName: "setlist", title: "셋리스트") {
                onSelect(.songList)
            }
            
            SidebarButtonView(imageName: "mypage", title: "마이페이지") {
                // 마이페이지 액션
            }
            
            SidebarButtonView(imageName: "mypage", title: "휴지통") {
                onSelect(.trashCan)
            }
            
            SidebarButtonView(imageName: "arrow.backward.square", title: "로그아웃") {
                logout()
            }
            
            Spacer()
        }
        .frame(maxWidth: 257, maxHeight: .infinity, alignment: .leading)
        .background(Color.white)
    }
    
    private func logout() {
            // lastLoggedInUserID 삭제
            UserDefaults.standard.removeObject(forKey: "lastLoggedInUserID")
            // /login 경로로 라우팅
            router.toNamed("/login")
        }
}
