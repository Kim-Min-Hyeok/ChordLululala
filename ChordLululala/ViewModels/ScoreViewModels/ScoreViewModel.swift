

import Combine
import SwiftUI
import PDFKit
import PencilKit

final class ScoreViewModel: ObservableObject{
    @Published var content: Content
    
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
    
    init(content: Content) {
        self.content = content
        self.chordBoxViewModel = ChordBoxViewModel()
        self.annotationViewModel = ScoreAnnotationViewModel()
        
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
    private func loadPages(_ content: Content, completion: (() -> Void)? = nil) {
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

        let contents: [Content] = {
            switch content.type {
            case ContentType.score.rawValue:
                return [content]
            case ContentType.setlist.rawValue:
                // Core Data에서 실제 자식 스코어들을 가져옴
                return ContentManager.shared.fetchScoresFromSetlist(content)
            default:
                return []
            }
        }()
        print("\(contents.count) 개의 스코어 로드 시작")

        var newImages:    [UIImage]         = []
        var newRotations: [Int]             = []
        var newDrawings:  [PKDrawing]       = []
        var newKey:          String         = "C"
        var newTKey:         String         = "C"
        var newChords:    [[ScoreChord]]    = []

        for c in contents {
            print("🎯 \(String(describing: c.name)) - scoreDetail=\(ScoreDetailManager.shared.fetchDetail(for: c) != nil), path=\(c.path ?? "nil")")
            guard let detail = ScoreDetailManager.shared.fetchDetail(for: c),
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
            
            newKey = detail.key ?? "C"
            newTKey = detail.t_key ?? "C"

            let pages = ScorePageManager.shared.fetchPages(for: detail)
            print("📑 \(String(describing: c.name)) - 페이지 수: \(pages.count)")
            for p in pages {
                // 4-a) 이미지 생성
                let img: UIImage
                if p.pageType == "pdf",
                   let page = pdf?.page(at: Int(p.originalPageIndex))  // Int16 → Int 캐스팅
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
                        if p.pageType == "staff",
                           let tpl = UIImage(named: "staff_template") {
                            tpl.draw(in: CGRect(origin: .zero, size: pageSize))
                        }
                    }
                }
                newImages.append(img)

                // 4-b) rotation
                newRotations.append(Int(p.rotation))
                
                // 4-c) annotation
                let annotationSet = (p.scoreAnnotations as? Set<ScoreAnnotation>) ?? []
                if let data = annotationSet.first?.strokeData,
                   let drawing = try? PKDrawing(data: data)
                {
                    newDrawings.append(drawing)
                } else {
                    newDrawings.append(PKDrawing())
                }
                
                // 4-d) chords
                let chordSet = (p.scoreChords as? Set<ScoreChord>) ?? []
                let chordArray = Array(chordSet)
                newChords.append(chordArray)
            }
        }

        // 5) 메인스레드에서 한 번에 갱신
        DispatchQueue.main.async {
                self.pages = newImages
                self.rotations = newRotations
                self.annotationViewModel.pageDrawings = newDrawings
                self.chordBoxViewModel.chordsForPages = newChords
                self.chordBoxViewModel.key = newKey
                self.chordBoxViewModel.t_key = newTKey
                completion?()
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
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: content) else {
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
            self.loadPages(self.content) {
                if self.pages.indices.contains(newIndex) {
                    self.currentPage = newIndex
                }
            }
        }
        return true
    }
    
    func deletePage(at index: Int) {
        // 1) 해당 Content의 ScoreDetail 엔티티 fetch
        guard let detailEntity = ScoreDetailManager.shared.fetchDetail(for: content) else {
            return
        }
        // 2) 페이지 리스트(fetch + 정렬)
        let pages = ScorePageManager.shared.fetchPages(for: detailEntity)
        // 3) 삭제할 페이지 엔티티 선택
        let pageToDelete = pages[index]
        // 4) 삭제 요청 (and reorder inside)
        guard ScorePageManager.shared.deletePage(pageToDelete) else {
            return
        }
        // 5) 화면 갱신
        DispatchQueue.main.async {
                self.loadPages(self.content) {
                    self.currentPage = max(0, min(index, self.pages.count - 1))
                }
            }
    }
    
    func rotatePage(clockwise: Bool) {
        // 1) Content → ScoreDetail 엔티티
        guard let detailEntity = ScoreDetailManager.shared.fetchDetail(for: content) else {
            return
        }
        // 2) 해당 detail의 페이지들(fetch + 정렬)
        let pages = ScorePageManager.shared.fetchPages(for: detailEntity)
        guard pages.indices.contains(currentPage) else { return }
        let pageEntity = pages[currentPage]

        // 3) 엔티티 직접 넘겨서 회전
        guard ScorePageManager.shared.rotatePage(pageEntity, clockwise: clockwise) else {
            return
        }

        // 4) 화면 갱신
        DispatchQueue.main.async {
            self.loadPages(self.content)
        }
    }
    
    func duplicatePage(at index: Int) {
        // 1) Content → ScoreDetail 엔티티 fetch
        guard let detailEntity = ScoreDetailManager.shared.fetchDetail(for: content) else {
            return
        }

        // 2) 해당 detail의 페이지 엔티티 배열(fetch + 정렬)
        let pages = ScorePageManager.shared.fetchPages(for: detailEntity)
        guard pages.indices.contains(index) else { return }
        let originalPage = pages[index]

        // 3) 원본 페이지 바로 복제
        guard let newPage = ScorePageManager.shared.clonePage(originalPage) else {
            return
        }

        // 4) 필기·코드 복제 (엔티티 기반)
        let annotations = ScoreAnnotationManager.shared.fetchAnnotations(for: originalPage)
        ScoreAnnotationManager.shared.cloneAnnotations(annotations, to: newPage)

        let chords = ScoreChordManager.shared.fetchChords(for: originalPage)
        ScoreChordManager.shared.cloneChords(chords, to: newPage)

        // 5) 화면 갱신 & 커서 이동
        DispatchQueue.main.async {
            self.loadPages(self.content) {
                self.currentPage = index + 1
            }
        }
    }
    
    func saveAnnotations() {
        annotationViewModel.saveAll(for: content)
    }
}


