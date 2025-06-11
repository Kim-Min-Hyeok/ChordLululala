

import Combine
import SwiftUI
import PDFKit
import PencilKit

final class ScoreViewModel: ObservableObject{
    @Published var content: ContentModel
    
    @Published var pages: [UIImage] = []
    @Published var currentPage: Int = 0
    
    // MARK: 모달뷰 Presented
    @Published var isAdditionModalView: Bool = false
    @Published var isOverViewModalView: Bool = false
    @Published var isSettingModalView: Bool = false
    
    // MARK: 각종 모드
    @Published var isAnnotationMode: Bool = false
    @Published var isPlayMode: Bool = false
    @Published var isSinglePageMode = true
    
    let pageAdditionViewModel = PageAdditionViewModel()
    let imageZoomeViewModel = ImageZoomViewModel()
    let scorePageOverViewModel = ScorePageOverViewModel()
    
    let chordBoxViewModel: ChordBoxViewModel
    let annotationViewModel: ScoreAnnotationViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel) {
        self.content = content
        self.chordBoxViewModel = ChordBoxViewModel(content: content)
        self.annotationViewModel = ScoreAnnotationViewModel(content: content)
        
        loadPages(content)
        
        $isAdditionModalView
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.pageAdditionViewModel.setContent(self.content)
                self.pageAdditionViewModel.currentPage = self.currentPage
            }
            .store(in: &cancellables)
    }
    
    // MARK: 페이지로드
    private func loadPages(_ content: ContentModel){
        
        /// ScoreDetail 불러오기
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content),
              let path = content.path,
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            DispatchQueue.main.async { self.pages = [] }
            return
        }
        
        let fileURL = docs.appendingPathComponent(path)
        
        guard let pdf = PDFDocument(url: fileURL) else {
            DispatchQueue.main.async { self.pages = [] }
            return
        }
        
        /// ScorePageModel 불러오기
        let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
        print(#fileID,#function,#line, "\(pageModels)")
        
        var newImages: [UIImage] = []
        let pageSize = pdf.page(at: 0)?.bounds(for: .mediaBox).size ?? CGSize(width: 539, height: 697)
        
        for pageModel in pageModels {
            if pageModel.pageType == "pdf" { // 원본 pdf 파일인 경우
                
                guard let page = pdf.page(at: Int(pageModel.originalPageIndex ?? 0 )) else { continue }
                let bounds = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: bounds.size)
                let img = renderer.image { ctx in
                    UIColor.white.setFill()
                    ctx.fill(bounds)
                    ctx.cgContext.translateBy(x: 0, y: bounds.height)
                    ctx.cgContext.scaleBy(x: 1, y: -1)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                newImages.append(img)
            } else {                 // 백지 또는 오선지인 경우
                let renderer = UIGraphicsImageRenderer(size: pageSize)
                let img = renderer.image { ctx in
                    // 백지인 경우
                    UIColor.white.setFill()
                    ctx.fill(CGRect(origin: .zero, size: pageSize))
                    
                    // 오선지인 경우
                    if pageModel.pageType == "staff" {
                        if let template = UIImage(named: "staff_template"){
                            template.draw(in: CGRect(origin: .zero, size:   pageSize))
                        }
                    }
                }
                newImages.append(img)
            }
        }
        
        DispatchQueue.main.async {
            self.pages = newImages
        }
        
    }
    
    // MARK: 페이지 이동 관련
    /// 맨 앞으로
    func goToFirstPage() {
        currentPage = 0
    }
    
    /// 맨 뒤로
    func goToLastPage() {
        currentPage = max(0, pages.count - 1)
    }
    
    /// 이전 페이지
    func goToPreviousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
    
    /// 다음 페이지
    func goToNextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }
    
    func addPage(type: PageType) {
        let newPageIndex = self.currentPage + 1
        annotationViewModel.pageDrawings.insert(PKDrawing(), at: newPageIndex)
        chordBoxViewModel.chordsForPages.insert([], at: newPageIndex)
        loadPages(self.content)
        currentPage = newPageIndex
    }
    
    func saveAnnotations() {
        annotationViewModel.saveAll(for: content)
    }
}


