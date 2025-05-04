

import Combine
import SwiftUI
import CoreData

final class ScoreViewModel: ObservableObject{
    
    @Published var content: ContentModel?
    
    let headerViewModel: ScoreHeaderViewModel
    let pdfViewModel: ScorePDFViewModel
    let playmodeViewModel = PlayModeViewModel()
    let pageNavViewModel: PageNavigationViewModel
    let annotationViewModel: ScoreAnnotationViewModel
    
    // 현재 페이지 인덱스
    @Published var currentPage: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel?    ) {
        // 1) 하위 VM 초기화
        self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
        self.pdfViewModel    = ScorePDFViewModel()
        self.pageNavViewModel = PageNavigationViewModel(pdfViewModel: pdfViewModel)
        self.annotationViewModel = ScoreAnnotationViewModel(
            contentId: content?.cid ?? UUID()
        )
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
        
        // 연주모드 변경
        playmodeViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        pageNavViewModel.$currentPage
            .sink { [weak self] newPage in
                guard let self = self else { return }
                // 이전 페이지 저장
                // (이전 페이지 번호는 combine 으로 처리하거나, annotation VM 에서 내부적으로 관리해도 됩니다)
                self.annotationViewModel.load(page: newPage)
            }
            .store(in: &cancellables)
        
        // 3) 초기 값 설정
        self.content = content
    }
}
