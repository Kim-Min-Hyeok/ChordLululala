//
//  SideBarView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스명")
                .font(.headline)
                .padding(.top, 23.03)
                .padding(.leading, 25)
                .padding(.bottom, 18.02)
            
            Divider()
            
            SidebarButtonView(imageName: "house.fill", title: "최근 열어본 문서") {
                withAnimation { viewModel.isSidebarVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if router.path.last?.name != "/recent" {
                        router.toNamed("/recent")
                    }
                }
            }
            
            SidebarButtonView(imageName: "doc.text", title: "전체 문서") {
                withAnimation { viewModel.isSidebarVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if router.path.last?.name != "/" {
                        router.toNamed("/")
                    }
                }
            }
            
            SidebarButtonView(imageName: "music.note", title: "송리스트") {
                withAnimation { viewModel.isSidebarVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if router.path.last?.name != "/songlist" {
                        router.toNamed("/songlist")
                    }
                }
            }
            
            SidebarButtonView(imageName: "trash", title: "휴지통") {
                withAnimation { viewModel.isSidebarVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if router.path.last?.name != "/trashcan" {
                        router.toNamed("/trashcan")
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.white)
        .shadow(radius: 5)
    }
}
