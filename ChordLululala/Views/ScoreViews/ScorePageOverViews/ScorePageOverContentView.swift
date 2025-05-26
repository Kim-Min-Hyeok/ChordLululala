//
//  ScorePageOverContentView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI

struct ScorePageOverContentView: View {
    @EnvironmentObject var vm : ScorePageOverViewModel
    
    let pageIndex : Int
    let image : UIImage
    var body: some View {
        VStack{
            //페이지
            Image(uiImage: image) // TODO: 이미지 사이즈  바꿔야 함
                .resizable()
                .scaledToFit()
                .frame(width: 99, height: 135)
                .cornerRadius(1)
                .shadow(color: Color.primaryBaseBlack.opacity(0.25) , radius: 3.24, x: 0, y: 3.24)
            
            HStack{
                Text("\(pageIndex)")
                    .textStyle(.headingLgSemiBold)
                Spacer()
                
                Button(action: {
                    //TODO: 모달 창 띄우기
                    vm.isPageOption()
                }){
                    Image("dropdown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 15)
                }
                .popover(
                    isPresented: $vm.isPageOptionModalPresented,
                    attachmentAnchor: .rect(.bounds),
                    arrowEdge: .top
                ){
                    PageOptionModalView()
                }
            }
            .foregroundColor(Color.primaryGray500)
            
        }
        .frame(width: 129, height: 167)
    }
}
