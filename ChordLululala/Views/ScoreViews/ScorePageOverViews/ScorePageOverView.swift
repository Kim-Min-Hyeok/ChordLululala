//
//  ScorePageOverView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct ScorePageOverView: View {
    @EnvironmentObject var vm : ScorePageOverViewModel
    
    var body: some View {
        
        
        VStack {
            HStack(){
                Spacer()
                Button(action:{
                    // TODO: 닫기 기능 추가
                    vm.toggle()
                }){
                    Text("닫기")
                        .foregroundColor(Color.primaryBlue600)
                        .textStyle(.headingSmMedium)
                }
            }
            
            ScorePageOverContentView(pageIndex: 1)  // TODO: 페이지 인덱스 바꿔야 함
            
            
        }
        .frame(width: 693, height: 663)
        .background(Color.primaryBaseWhite)
        .cornerRadius(17)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15),radius: 30 )
        
        
    }
}
