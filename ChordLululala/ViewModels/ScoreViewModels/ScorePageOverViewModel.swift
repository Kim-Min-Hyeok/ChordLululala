//
//  ScorePageOverViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import Foundation


final class ScorePageOverViewModel: ObservableObject {
    @Published var isPageOver: Bool = false
    @Published var isAddPageModalPresented : Bool = false
    @Published var isPageOptionModalPresented : Bool = false
    
    //모아보기 모달 띄우기
    func toggle(){
        isPageOver.toggle()
    }
    
    // 마지막 파란색 페이지 추가 버튼 눌렀을떄 뜨는 모달
    func isAddPage(){
        isAddPageModalPresented.toggle()
    }
    
    // 페이지 지우기, 회전하기 모달 띄우기
    func isPageOption(){
        isPageOptionModalPresented.toggle()
    }
    
    
    
}
