//
//  PageNavigationViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/3/25.
//

import Combine

/// 연주모드시 화면 이동 기능
final class PageNavigationViewModel: ObservableObject{
    
    @Published var currentPage: Int = 0
    
    private let pdfViewModel: ScorePDFViewModel
    
    init(pdfViewModel: ScorePDFViewModel) {
        self.pdfViewModel = pdfViewModel
    }
    /// 맨 앞으로
    func goToFirstPage() {
        currentPage = 0
    }
    
    /// 맨 뒤로
    func goToLastPage() {
        currentPage = max(0, pdfViewModel.images.count - 1)
    }
    
    /// 이전 페이지
    func goToPreviousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
    
    /// 다음 페이지
    func goToNextPage() {
        guard currentPage < pdfViewModel.images.count - 1 else { return }
        currentPage += 1
    }
}
