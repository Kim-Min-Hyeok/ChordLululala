

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
    // 현재 페이지 인덱스
    @Published var currentPage: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel?    ) {
        // 1) 하위 VM 초기화
        self.headerViewModel = ScoreHeaderViewModel(title: content?.name ?? "")
        self.pdfViewModel    = ScorePDFViewModel()
        self.pageAdditionViewModel = PageAdditionViewModel(pdfViewModel: pdfViewModel)
        self.pageNavViewModel = PageNavigationViewModel(pdfViewModel: pdfViewModel)
        let context = CoreDataManager.shared.context
           if let content = content {
               // 기존 ScorePage 찾기 또는 새로 생성
               let fetchRequest: NSFetchRequest<ScorePage> = ScorePage.fetchRequest()
               fetchRequest.predicate = NSPredicate(format: "s_pid == %@", content.cid as CVarArg)
               
               let pageEntity: ScorePage
               if let existingPage = try? context.fetch(fetchRequest).first {
                   pageEntity = existingPage
               } else {
                   pageEntity = ScorePage(context: context)
                   pageEntity.s_pid = content.cid
                   pageEntity.rotation = 0
                   try? context.save()
               }
               
               self.annotationViewModel = ScoreAnnotationViewModel(pageModel: ScorePageModel(entity: pageEntity))
           } else {
               // 새로운 ScorePage 생성
               let pageEntity = ScorePage(context: context)
               pageEntity.s_pid = UUID()
               pageEntity.rotation = 0
               try? context.save()
               
               self.annotationViewModel = ScoreAnnotationViewModel(pageModel: ScorePageModel(entity: pageEntity))
           }
           
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
                //                self.annotationViewModel.load(page: newPage) // TODO: 필기 저장하는 기능 구현해야함
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
