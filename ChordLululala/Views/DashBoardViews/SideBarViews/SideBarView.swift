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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스명")
                .font(.headline)
                .padding(.top, 23.03)
                .padding(.leading, 25)
                .padding(.bottom, 18.02)
            
            Divider()
            
            SidebarButtonView(imageName: "house.fill", title: "최근 열어본 문서") {
                onSelect(.recentDocuments)
            }
            
            SidebarButtonView(imageName: "doc.text", title: "전체 문서") {
                onSelect(.allDocuments)
            }
            
            SidebarButtonView(imageName: "music.note", title: "송리스트") {
                onSelect(.songList)
            }
            
            SidebarButtonView(imageName: "trash", title: "휴지통") {
                onSelect(.trashCan)
            }
            
            Spacer()
        }
        .frame(maxWidth: 257, maxHeight: .infinity, alignment: .leading)
        .background(Color.white)
    }
}
