

import Combine
import SwiftUI

final class ScoreViewModel: ObservableObject{
    
    @Published var content: ContentModel?
    
    let headerViewModel: ScoreHeaderViewModel
    let pdfViewModel: ScorePDFViewModel

    // 현재 페이지 인덱스
    @Published var currentPage: Int = 0

    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel?) {
            // 1) 하위 VM 초기화
            self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
            self.pdfViewModel    = ScorePDFViewModel()
            
            // 2) Combine 파이프라인 설정
            // content.name → headerViewModel.title
            $content
                .compactMap { $0?.name }         // nil 무시
                .removeDuplicates()              // 중복 방지
                .sink { [headerViewModel] name in
                    headerViewModel.title = name
                }
                .store(in: &cancellables)
            
            // content → pdfViewModel.updateContent(_:)
            $content
                .sink { [pdfViewModel] content in
                    pdfViewModel.updateContent(content)
                }
                .store(in: &cancellables)
            
            // 3) 초기 값 설정
            self.content = content
        }
}
