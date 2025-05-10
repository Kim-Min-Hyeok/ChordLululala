//
//  PageAdditionViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/6/25.
//

import SwiftUI

enum PageType{
    case blank // 빈종이
    case staff // 오선지
}

final class PageAdditionViewModel: ObservableObject{
    @Published var isSheetPresented: Bool = false
    @Published var isBlankPage: Bool = true
    
    private let pdfViewModel: ScorePDFViewModel
    

    init(pdfViewModel: ScorePDFViewModel){
        self.pdfViewModel = pdfViewModel
    }
    
    /// “페이지 추가” 버튼 눌렀을 때 호출
      func presentSheet() {
          isSheetPresented = true
          print("페이지 추가 버튼 눌림")
      }
      
      /// 모달에서 선택된 타입으로 실제 페이지 추가
      func addPage(_ type: PageType) {
          pdfViewModel.addPage(type)
          print("페이지 추가됨")
          isSheetPresented = false
      }
}
