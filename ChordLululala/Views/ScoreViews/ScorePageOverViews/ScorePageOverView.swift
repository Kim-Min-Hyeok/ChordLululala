//
//  ScorePageOverView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct ScorePageOverView: View {
    @EnvironmentObject var vm : ScorePageOverViewModel
    @EnvironmentObject var pageVM : ScorePDFViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        
        VStack(spacing: 0){
            HStack(){
                Spacer()
                Button(action:{
                    vm.toggle()
                }){
                    Text("닫기")
                        .foregroundColor(Color.primaryBlue600)
                        .textStyle(.headingSmMedium)
                        .padding(.trailing, 23)
                        .padding(.vertical, 7)
                }
            }
            .frame(height: 36)
            .background(Color.primaryGray50)
            .padding(.bottom, 24)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30){
                    ForEach(pageVM.images.indices , id: \.self) { idx in
                        VStack {
                            ScorePageOverContentView(
                                pageIndex: idx+1,
                                image: pageVM.images[idx]
                            )
                        }
                    }
                    PageAddButtonView()
                }
            }
        }
        .frame(width: 693, height: 663)
        .background(Color.primaryBaseWhite)
        .cornerRadius(17)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15),radius: 30 )
    }
}
