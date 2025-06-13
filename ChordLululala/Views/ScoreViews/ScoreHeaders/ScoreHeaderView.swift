//
//  ScoreHeaderView.swift
//  ChordLululala
//
//  Created by 김민준 on 3/26/25.
//

import SwiftUI


struct ScoreHeaderView: View {
    @EnvironmentObject var router : NavigationRouter
    
    @State var isAnnotationMode: Bool = false
    
    // Pararameter
    let file : Content
    
    let presentSetlistOverViewModal: () -> Void
    let toggleAnnotationMode: () -> Void
    let presentAddPageModal: () -> Void
    let presentOverViewModal: () -> Void
    let toggleSettingViewModal: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing:0){
                /// 뒤로가기
                Button(action:{
                    router.back()
                }){
                    Image("scoreheader_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.primaryBaseBlack)
                }
                
                if file.type == ContentType.setlist.rawValue {
                    Button(action:{
                        presentSetlistOverViewModal()
                    }){
                        Image("scoreheader_score_list")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    }
                    .padding(.leading, 7)
                }
                
                Spacer()
                
                HStack(spacing: 7){
                    /// 펜슬
                    Button(action:{
                        isAnnotationMode.toggle()
                        toggleAnnotationMode()
                    }){
                        Image(isAnnotationMode ? "scoreheader_pencil_fill" : "scoreheader_pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color.primaryGray900)
                    }
                    .padding(.trailing,10)
                    
                    /// 페이지 추가버튼
                    Button(action:{
                        presentAddPageModal()
                    }){
                        Image("scoreheader_page_add")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color.primaryBaseBlack)
                    }
                    
                    if file.type == ContentType.score.rawValue {
                        /// 키변환
                        Button(action:{
                            router.toNamed("/chordreconize", arguments: [ file ])
                            
                        }){
                            HStack{
                                Image("scoreheader_chordchange")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                
                                Text("키변환")
                                    .textStyle(.headingLgMedium)
                            }
                        }
                        .frame(width: 94, height: 42)
                        .background(Color.primaryBlue500)
                        .foregroundColor(Color.primaryBaseWhite)
                        .cornerRadius(8)
                        .padding(.trailing,10)
                    }
                    
                    ///전체 페이지 보기
                    Button(action:{
                        presentOverViewModal()
                    }){
                        Image("scoreheader_page_list")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color.primaryBaseBlack)
                        
                    }
                    
                    ///설정
                    Button(action:{
                        toggleSettingViewModal()
                        print("설정 보기 클릭") //TODO: 기능 추가해야함
                    }){
                        Image("scoreheader_setting")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color.primaryBaseBlack)
                        
                    }
                }
                
            }
            .padding(.horizontal, 22)
            .frame(height:91,
                   alignment: .bottom)
            
            /// 제목
            Text({
                let name = file.name ?? ""
                return name.count > 10 ? "\(name.prefix(10))…" : name
            }())
            .foregroundColor(Color.primaryGray900)
            .textStyle(.headingLgSemiBold)
            .layoutPriority(1)
            .lineLimit(1)
            .padding(.bottom, 12)
        }
    }
}
