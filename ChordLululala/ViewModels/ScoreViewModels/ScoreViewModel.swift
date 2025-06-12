

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
    
    // MARK: 페이지로드 (Score · Setlist 모두 지원)
    private func loadPages(_ content: ContentModel) {
        // 1) 도큐먼트 디렉토리 확보
        guard let docs = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first
        else {
            DispatchQueue.main.async {
                self.pages = []
                self.rotations = []
                self.annotationViewModel.pageDrawings = []
                self.chordBoxViewModel.chordsForPages = []
            }
            return
        }

        // 2) 로드할 ContentModel 결정
        let contentModels: [ContentModel] = {
            switch content.type {
            case .score:
                return [content]
            case .setlist:
                // Core Data에서 실제 자식 스코어들을 가져옴
                return ContentManager.shared.fetchScoresFromSetlist(content)
            default:
                return []
            }
        }()
        print("\(contentModels.count) 개의 스코어 로드 시작")

        var newImages:    [UIImage]         = []
        var newRotations: [Int]             = []
        var newDrawings:  [PKDrawing]       = []
        var newChords:    [[ScoreChordModel]] = []

        // 3) 각 ContentModel → ScoreDetailModel → ScorePage 순회
        for c in contentModels {
            print("🎯 \(c.name) - scoreDetail=\(ScoreDetailManager.shared.fetchScoreDetailModel(for: c) != nil), path=\(c.path ?? "nil")")
            guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: c),
                  let relPath = c.path else {
                print("❌ detail 또는 path 없음, skip")
                continue
            }

            let fileURL = docs.appendingPathComponent(relPath)
            let pdf     = PDFDocument(url: fileURL)
            let pageSize = pdf?
                .page(at: 0)?
                .bounds(for: .mediaBox).size
                ?? CGSize(width: 539, height: 697)

            let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
            print("📑 \(c.name) - 페이지 수: \(pageModels.count)")
            for pm in pageModels {
                // 4-a) 이미지 생성
                let img: UIImage
                if pm.pageType == "pdf",
                   let idx  = pm.originalPageIndex,
                   let page = pdf?.page(at: idx)
                {
                    let bounds   = page.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: bounds.size)
                    img = renderer.image { ctx in
                        UIColor.white.setFill(); ctx.fill(bounds)
                        ctx.cgContext.translateBy(x: 0, y: bounds.height)
                        ctx.cgContext.scaleBy(x: 1, y: -1)
                        page.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                } else {
                    let renderer = UIGraphicsImageRenderer(size: pageSize)
                    img = renderer.image { ctx in
                        UIColor.white.setFill()
                        ctx.fill(CGRect(origin: .zero, size: pageSize))
                        if pm.pageType == "staff",
                           let tpl = UIImage(named: "staff_template") {
                            tpl.draw(in: CGRect(origin: .zero, size: pageSize))
                        }
                    }
                }
                newImages.append(img)

                // 4-b) rotation
                newRotations.append(pm.rotation)

                // 4-c) annotation
                if let data = pm.scoreAnnotations.first?.strokeData,
                   let drawing = try? PKDrawing(data: data)
                {
                    newDrawings.append(drawing)
                } else {
                    newDrawings.append(PKDrawing())
                }

                // 4-d) chords
                newChords.append(pm.scoreChords)
            }
        }

        // 5) 메인스레드에서 한 번에 갱신
        DispatchQueue.main.async {
            self.pages = newImages
            self.rotations = newRotations
            self.annotationViewModel.pageDrawings = newDrawings
            self.chordBoxViewModel.chordsForPages = newChords
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
    
    func duplicatePage(at index: Int) {
        // 1) ScoreDetailModel 조회
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else { return }
        
        // 2) 원본 PageModel, Annotation, Chord 모델들 가져오기
        let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
        let originalPage = pageModels[index]
        let annotations = ScoreAnnotationManager2.shared.fetch(for: originalPage)
        let chords      = ScoreChordManager.shared.fetch(for: originalPage)
        
        // 3) Core Data에 페이지 복제
        guard let newPageModel = ScorePageManager.shared.duplicatePage(for: detail, at: index) else { return }
        
        // 4) 필기·코드 복제
        ScoreAnnotationManager2.shared.clone(from: annotations, to: newPageModel)
        ScoreChordManager.shared.clone(from: chords, to: newPageModel)
        
        // 5) 화면 갱신 & 커서 이동
        DispatchQueue.main.async {
            self.loadPages(self.content)
            // 복제된 페이지로 이동
            self.currentPage = index + 1
        }
    }
    
    func saveAnnotations() {
        annotationViewModel.saveAll(for: content)
    }
}


