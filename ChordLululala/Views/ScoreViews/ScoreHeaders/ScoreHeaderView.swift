//
//  ScoreHeaderView.swift
//  ChordLululala
//
//  Created by 김민준 on 3/26/25.
//

import SwiftUI


struct ScoreHeaderView: View {
    @EnvironmentObject var router : NavigationRouter
    @State var title: String
    
    var body: some View {
        HStack{
            // 뒤로가기
            Button(action:{
                router.back()
            }){
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            
            
            Spacer()
            
            // 제목
            Text(title)
                .fontWeight(.semibold)
            
            Spacer()
            
            // 펜슬
            Button(action:{
                
                
                print("펜슬 기능 클릭") // 기능 추가해야함
            }){
                Image(systemName: "pencil.circle.fill") // 이미지 바꿔야 함
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            // 메모장
            Button(action:{
                
                print("메모장 기능 클릭") // 기능 추가해야함
            }){
                Text("메모장")
                    .foregroundColor(Color.black)
            }
            .padding(.trailing,10)
            
            // 키변환
            Button(action:{
                
                print("키변환 기능 클릭") // 기능 추가해야함
            }){
                Text("키변환")
                    .foregroundColor(Color.blue)
            }
            .padding(.trailing,10)
            
            // 설정
            Button(action:{
                
                print("설정 기능 클릭") // 기능 추가해야함
            }){
                Image(systemName: "gear") // 이미지 바꿔야 함
                    .foregroundColor(Color.black)
            }
        }
        .frame(height: 83)
        .padding(.horizontal)
    }
}
