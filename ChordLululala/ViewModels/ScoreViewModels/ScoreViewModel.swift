

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
    
    // MARK: 페이지 설정
    @Published private(set) var rotations: [Int] = []
    
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
    private func loadPages(_ content: ContentModel) {
        guard
            let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content),
            let path   = content.path,
            let docs   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            DispatchQueue.main.async {
                self.pages = []
                self.annotationViewModel.pageDrawings = []
                self.chordBoxViewModel.chordsForPages = []
            }
            return
        }
        
        let fileURL    = docs.appendingPathComponent(path)
        let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
        let newRotations = pageModels.map { $0.rotation }
        
        // 1) 이미지 렌더링
        var newImages: [UIImage] = []
        let pageSize = PDFDocument(url: fileURL)?
            .page(at: 0)?
            .bounds(for: .mediaBox).size
        ?? CGSize(width: 539, height: 697)
        
        let pdf = PDFDocument(url: fileURL)
        for pageModel in pageModels {
            let base: UIImage
            if pageModel.pageType == "pdf", let page = pdf?.page(at: Int(pageModel.originalPageIndex ?? 0)) {
                let bounds   = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: bounds.size)
                base = renderer.image { ctx in
                    UIColor.white.setFill(); ctx.fill(bounds)
                    ctx.cgContext.translateBy(x: 0, y: bounds.height)
                    ctx.cgContext.scaleBy(x: 1, y: -1)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
            } else {
                let renderer = UIGraphicsImageRenderer(size: pageSize)
                base = renderer.image { ctx in
                    UIColor.white.setFill()
                    ctx.fill(CGRect(origin: .zero, size: pageSize))
                    if pageModel.pageType == "staff",
                       let tpl = UIImage(named: "staff_template") {
                        tpl.draw(in: CGRect(origin: .zero, size: pageSize))
                    }
                }
            }
            newImages.append(base)
        }
        
        // 2) Annotation & Chord 뷰모델 동기화
        //    ScoreAnnotationModel 에는 strokeData(Data)가, ScoreChordModel 에는 chord 정보가 들어 있다고 가정
        let drawings: [PKDrawing] = pageModels.map { pm in
            guard
                let annData = pm.scoreAnnotations.first?.strokeData,
                let drawing = try? PKDrawing(data: annData)
            else {
                return PKDrawing()
            }
            return drawing
        }
        let chords: [[ScoreChordModel]] = pageModels.map { $0.scoreChords }
        
        // 3) 메인스레드에서 한 번에 갱신
        DispatchQueue.main.async {
            self.pages = newImages
            self.rotations = newRotations
            self.annotationViewModel.pageDrawings = drawings
            self.chordBoxViewModel.chordsForPages = chords
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
    
    @discardableResult
    func addPage(at index: Int, type: PageType) -> Bool {
        // 1) Core Data에서 ScoreDetail 조회
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else {
            return false
        }
        // 삽입 후 보여줄 새 페이지 인덱스
        let newIndex = index + 1
        
        // 2) Core Data에 페이지 추가 (afterIndex: index)
        guard let _ = ScorePageManager.shared.addPage(for: detail, afterIndex: index, type: type) else {
            return false
        }
        
        // 3) 뷰 업데이트가 끝난 뒤 전체 다시 로드
        DispatchQueue.main.async {
            self.loadPages(self.content)
            if self.currentPage == index {
                self.currentPage = newIndex
            }
        }
        return true
    }
    
    func deletePage(at index: Int) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else { return }
        let models = ScorePageManager.shared.fetchPageModels(for: detail)
        let modelToDelete = models[index]
        
        // 1) Core Data에서 삭제
        guard ScorePageManager.shared.deletePage(with: modelToDelete.s_pid) else { return }
        
        // 2) 뷰 업데이트가 끝난 뒤 전체 다시 로드
        DispatchQueue.main.async {
            self.loadPages(self.content)
            self.currentPage = max(0, min(self.currentPage, self.pages.count - 1))
        }
    }
    
    func rotatePage(clockwise: Bool) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else { return }
        let models = ScorePageManager.shared.fetchPageModels(for: detail)
        let currentModel = models[currentPage]
        
        // Core Data에 rotation 값 저장
        guard ScorePageManager.shared.rotatePage(with: currentModel.s_pid, clockwise: clockwise) else { return }
        
        // 뷰 업데이트가 끝난 뒤 전체 페이지 다시 로드
        DispatchQueue.main.async {
            self.loadPages(self.content)
        }
    }
    
    func saveAnnotations() {
        annotationViewModel.saveAll(for: content)
    }
}


