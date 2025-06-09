

import Combine
import SwiftUI
import CoreData

final class ScoreViewModel: ObservableObject{

    @Published var content: ContentModel?

    let headerViewModel: ScoreHeaderViewModel
    let pdfViewModel: ScorePDFViewModel
    let pageAdditionViewModel: PageAdditionViewModel
    let playmodeViewModel = PlayModeViewModel()
    let pageNavViewModel: PageNavigationViewModel
    let annotationViewModel: ScoreAnnotationViewModel
    let isTransposingViewModel = IsTransposingViewModel()
    let scoreSettingViewModel = ScoreSettingViewModel()
    let scorePageOverViewModel = ScorePageOverViewModel()
    let chordBoxViewModel: ChordBoxViewModel
    // 현재 페이지 인덱스
    @Published var currentPage: Int = 0

    private var cancellables = Set<AnyCancellable>()

    init(content: ContentModel?) {
        // 1) 하위 VM 초기화
        self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
        self.pdfViewModel    = ScorePDFViewModel()
        self.pageNavViewModel = PageNavigationViewModel(pdfViewModel: pdfViewModel)
        self.pageAdditionViewModel = PageAdditionViewModel(pdfViewModel: pdfViewModel, pageNavViewModel: pageNavViewModel)
        self.annotationViewModel = ScoreAnnotationViewModel(content: content)
        self.chordBoxViewModel = ChordBoxViewModel(content: content)
        
        self.pageAdditionViewModel.setContent(content)
        
        
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

        $content
            .sink { [pageAdditionViewModel] content in
                pageAdditionViewModel.setContent(content)
            }
            .store(in: &cancellables)
        
        // 연주모드 변경
        playmodeViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        // 모아 보기 변경
        scorePageOverViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)



        // 한페이지, 두페이지씩 보기 변경
        scoreSettingViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)


        pageNavViewModel.$currentPage
            .sink { [weak self] newPage in
                guard let self = self else { return }
                if newPage < self.annotationViewModel.pageModels.count {
                    let pageModels = self.annotationViewModel.pageModels[newPage]
                    self.annotationViewModel.switchToPage(pageId: pageModels.s_pid)
                }
            }
            .store(in: &cancellables)

        pageAdditionViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)


        // 3) 초기 값 설정
        self.content = content
    }


}


