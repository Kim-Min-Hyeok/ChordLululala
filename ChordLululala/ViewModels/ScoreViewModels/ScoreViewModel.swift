

import Combine
import SwiftUI
import PDFKit
import PencilKit

final class ScoreViewModel: ObservableObject{
    @Published private(set) var content: Content // 최상위 Content .score/.setlist
    @Published var scores: [Content] = []
    @Published var selectedPageIndex: Int = 0
    
    @Published private(set) var pagesForScores: [[UIImage]] = []
    @Published private(set) var rotationsForScores: [[Int]] = []
    @Published private(set) var isRecognizedForScores: [Bool] = []
    @Published private(set) var scoreKeys:   [String] = []
    @Published private(set) var scoreTKeys:  [String] = []
    @Published private(set) var chordsForScores: [[[ScoreChord]]] = []
    @Published private(set) var annotationsForScores: [[PKDrawing]] = []
    
    @Published var currentScoreRecognized: Bool = false
    
    // 모든 악보 합친 전체 페이지
    var flatPages: [UIImage] { pagesForScores.flatMap { $0 } }
    var flatRotations: [Int] { rotationsForScores.flatMap { $0 } }
    var flatChordsForPages: [[ScoreChord]] {
        return chordsForScores.flatMap { $0 }
    }
    var flatKeys: [String] {
        zip(scoreKeys, pagesForScores)
            .flatMap { key, pages in Array(repeating: key, count: pages.count) }
    }
    var flatTKeys: [String] {
        zip(scoreTKeys, pagesForScores)
            .flatMap { t_key, pages in Array(repeating: t_key, count: pages.count) }
    }
    var flatAnnotations: [PKDrawing] {
            annotationsForScores.flatMap { $0 }
        }
    
    private func splitFlatIndex(_ flat: Int) -> (scoreIndex: Int, pageIndex: Int)? {
        var offset = 0
        for (i, pages) in pagesForScores.enumerated() {
            if flat < offset + pages.count {
                return (i, flat - offset)
            }
            offset += pages.count
        }
        return nil
    }
    
    // MARK: 모달 뷰
    @Published var isSetlistOverViewModalView: Bool = false
    @Published var isAdditionModalView: Bool = false
    @Published var isOverViewModalView: Bool = false
    @Published var isSettingModalView: Bool = false
    @Published var isChordResetModalView: Bool = false
    
    // MARK: 각종 모드
    @Published var isAnnotationMode: Bool = false
    @Published var isPlayMode: Bool = false
    @Published var isSinglePageMode = true
    
    let imageZoomeViewModel = ImageZoomViewModel()
    let chordBoxViewModel = ChordBoxViewModel()
    let scoreAnnotationViewModel = ScoreAnnotationViewModel()
    let scoreSetlistOverViewModel = ScoreSetlistOverViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(content: Content) {
        self.content = content
        
        if content.type == ContentType.setlist.rawValue {
            scores = ContentManager.shared.fetchScoresFromSetlist(content)
        } else if content.type == ContentType.score.rawValue || content.type == ContentType.scoresOfSetlist.rawValue {
            self.scores = [content]
            print("Single score mode with content:", content.name ?? "Unknown")
        }
        
        bindInputs()
        loadAllScoresData()
    }
    
    private func bindInputs() {
        // 악보 목록 변경 시 모든 데이터 갱신
//        $scores
//            .sink { [weak self] _ in
//                self?.loadAllScoresData()
//            }
//            .store(in: &cancellables)
        
//        $selectedPageIndex
//            .dropFirst()
//            .sink { [weak self] _ in
//                self?.saveAnnotations()
//            }
//            .store(in: &cancellables)
        
        Publishers
            .CombineLatest($selectedPageIndex, $isRecognizedForScores)
            .map { flatIndex, recs in
                var offset = 0
                for (i, pages) in self.pagesForScores.enumerated() {
                    if flatIndex < offset + pages.count {
                        return recs.indices.contains(i) ? recs[i] : false
                    }
                    offset += pages.count
                }
                return false
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.currentScoreRecognized = newValue
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didTransposeChord)
            .compactMap { $0.object as? Content }
            .sink { [weak self] updated in
                guard let s = self else { return }
                // find score index and reload that score
                if let idx = s.scores.firstIndex(where: { $0.id == updated.id }) {
                    s.loadScoreData(at: idx)
                }
            }
            .store(in: &cancellables)
        
    }
    
    func loadAllScoresData() {
        let items = scores
        DispatchQueue.global(qos: .userInitiated).async {
            var allPages = [[UIImage]]()
            var allRots = [[Int]]()
            var allRecog = [Bool]()
            var allKeys = [String]()
            var allTKeys = [String]()
            var allChords: [[[ScoreChord]]] = []
            var allDrawings   = [[PKDrawing]]()
            
            for c in items {
                let (imgs, rots, recog, chordsPerPage, key, t_key, drawingsPerPage) = self.loadPagesSyncDetailed(for: c)
                allPages.append(imgs)
                allRots.append(rots)
                allRecog.append(recog)
                allChords.append(chordsPerPage)
                allKeys.append(key)
                allTKeys.append(t_key)
                allDrawings.append(drawingsPerPage)
            }
            DispatchQueue.main.async {
                self.pagesForScores     = allPages
                self.rotationsForScores = allRots
                self.isRecognizedForScores = allRecog
                self.chordsForScores    = allChords
                self.scoreKeys          = allKeys
                self.scoreTKeys         = allTKeys
                self.annotationsForScores = allDrawings
                
                self.chordBoxViewModel.chordsForPages = self.flatChordsForPages
                self.chordBoxViewModel.pageKeys   = self.flatKeys
                self.chordBoxViewModel.pageTKeys = self.flatTKeys
                
                self.scoreAnnotationViewModel.pageDrawings = self.flatAnnotations
                
                self.selectedPageIndex = min(
                    self.selectedPageIndex,
                    self.flatPages.count - 1
                )
            }
        }
    }

    private func loadScoreData(at index: Int) {
        guard scores.indices.contains(index) else { return }
        let content = scores[index]
        DispatchQueue.global(qos: .userInitiated).async {
            let (imgs, rots, recog, chordsPerPage, key, t_key, drawingsPerPage)
                = self.loadPagesSyncDetailed(for: content)
            
            DispatchQueue.main.async {
                self.pagesForScores[index]            = imgs
                self.rotationsForScores[index]        = rots
                self.isRecognizedForScores[index]     = recog
                self.chordsForScores[index]           = chordsPerPage
                self.scoreKeys[index]                 = key
                self.scoreTKeys[index]                = t_key
                self.annotationsForScores[index]      = drawingsPerPage  // ← 반영
                
                // flat 으로 뷰모델에 넘겨주기
                self.chordBoxViewModel.chordsForPages   = self.flatChordsForPages
                self.chordBoxViewModel.pageKeys         = self.flatKeys
                self.chordBoxViewModel.pageTKeys        = self.flatTKeys
                
                self.scoreAnnotationViewModel.pageDrawings = self.flatAnnotations
            }
        }
    }

    private func loadPagesSyncDetailed(
        for content: Content
    ) -> (
        [UIImage], [Int], Bool,
        [[ScoreChord]], String, String,
        [PKDrawing]
    ) {
        var imgs       = [UIImage]()
        var rots       = [Int]()
        var recog      = false
        var chordsAll  = [[ScoreChord]]()
        var drawings   = [PKDrawing]()
        var key        = "C"
        var t_key      = "C"
        
        guard let docs   = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first,
              let detail = ScoreDetailManager.shared.fetchDetail(for: content)
        else {
            return ([], [], false, [], key, t_key, [])
        }
        
        key   = detail.key   ?? "C"
        t_key = detail.t_key ?? "C"
        
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        for p in pages {
            // 1) 이미지 & 회전
            imgs.append(makeImage(for: p, content: content, docsURL: docs))
            rots.append(Int(p.rotation))
            
            // 2) 페이지별 chords 배열
            let pageChords = (p.scoreChords as? Set<ScoreChord>)?
                .sorted {
                    $0.objectID.uriRepresentation().absoluteString
                    < $1.objectID.uriRepresentation().absoluteString
                } ?? []
            chordsAll.append(pageChords)
            if !pageChords.isEmpty { recog = true }
            
            // 3) 페이지별 annotation
            if let firstAnnot = (p.scoreAnnotations as? Set<ScoreAnnotation>)?.first,
               let data = firstAnnot.strokeData,
               let drawing = try? PKDrawing(data: data)
            {
                drawings.append(drawing)
            } else {
                drawings.append(PKDrawing())
            }
        }
        
        return (imgs, rots, recog, chordsAll, key, t_key, drawings)
    }
    
    private func makeImage(for page: ScorePage, content: Content, docsURL: URL) -> UIImage {
        let url = docsURL.appendingPathComponent(content.path ?? "")
        let pdf = PDFDocument(url: url)
        let size = pdf?.page(at: 0)?.bounds(for: .mediaBox).size ?? CGSize(width: 539, height: 697)
        if page.pageType == "pdf", let pdfPage = pdf?.page(at: Int(page.originalPageIndex)) {
            let bounds = pdfPage.bounds(for: .mediaBox)
            return UIGraphicsImageRenderer(size: bounds.size).image { ctx in
                UIColor.white.setFill(); ctx.fill(bounds)
                ctx.cgContext.translateBy(x: 0, y: bounds.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
            }
        }
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
            if page.pageType == "staff", let tpl = UIImage(named: "staff_template") {
                tpl.draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
    
    // MARK: 페이지 이동 관련
    /// 맨 앞으로
    func goToFirstPage() { selectedPageIndex = 0 }
    func goToLastPage() { selectedPageIndex = max(0, flatPages.count - 1) }
    func goToPreviousPage() { if selectedPageIndex > 0 { selectedPageIndex -= 1 } }
    func goToNextPage()     { if selectedPageIndex < flatPages.count - 1 { selectedPageIndex += 1 } }
    
    func moveScore(from source: IndexSet, to destination: Int) {
        scores.move(fromOffsets: source, toOffset: destination)
        
        // Core Data 저장 완료 후 ViewModel 갱신
        DispatchQueue.global(qos: .userInitiated).async {
            ContentManager.shared.updateSetlistDisplayOrder(for: self.scores)
            
            DispatchQueue.main.async {
                self.loadAllScoresData()
            }
        }
    }
    
    func deleteScore(_ score: Content) {
        if let idx = scores.firstIndex(where: { $0.objectID == score.objectID }),
           ContentManager.shared.removeScoreFromSetlist(score, in: scores)
        {
            scores.remove(at: idx)
            loadAllScoresData()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // flatPages의 마지막 인덱스로 클램프
                self.selectedPageIndex = min(self.selectedPageIndex, max(0, self.flatPages.count - 1))
            }
        }
    }
    
    func addScores(_ scores: [Content]) {
        let now = Date()
        let lastOrder = self.scores.map { Int($0.displayOrder) }.max() ?? -1

        let newScoreEntities: [Content] = scores.enumerated().map { (offset, orig) in
            let cloned = ContentCoreDataManager.shared.createContent(
                name: orig.name ?? "",
                path: orig.path,
                type: ContentType.scoresOfSetlist.rawValue,
                parent: nil
            )
            cloned.createdAt      = now
            cloned.modifiedAt     = now
            cloned.lastAccessedAt = now
            cloned.displayOrder   = Int16(lastOrder + offset + 1)
            cloned.setlist        = self.content

            // ----- 아래 Deep Clone 로직 추가 -----
            // 1) Detail 복제
            if let origDetail = ScoreDetailManager.shared.fetchDetail(for: orig) {
                let newDetail = ScoreDetailManager.shared.cloneDetail(of: origDetail, to: cloned)
                // 2) Page 복제
                let origPages = ScorePageManager.shared.fetchPages(for: origDetail)
                let newPages  = ScorePageManager.shared.clonePages(from: origPages, to: newDetail)
                // 3) 코드/어노테이션 복제
                for (origPage, newPage) in zip(origPages, newPages) {
                    let chords = ScoreChordManager.shared.fetchChords(for: origPage)
                    ScoreChordManager.shared.cloneChords(chords, to: newPage)
                    let annots = ScoreAnnotationManager.shared.fetchAnnotations(for: origPage)
                    ScoreAnnotationManager.shared.cloneAnnotations(annots, to: newPage)
                }
            }
            // -------------------------------------
            return cloned
        }

        let mutableScores = self.content.mutableSetValue(forKey: "setlistScores")
        for entity in newScoreEntities {
            mutableScores.add(entity)
        }
        CoreDataManager.shared.saveContext()

        self.scores = ContentManager.shared.fetchScoresFromSetlist(self.content)
        self.loadAllScoresData()
    }
    
    @discardableResult
    func addPage(atFlatIndex flat: Int, type: PageType) -> Bool {
        guard let (si, pi) = splitFlatIndex(flat),
              let detail = ScoreDetailManager.shared.fetchDetail(for: scores[si]),
              ScorePageManager.shared.addPage(for: detail, afterIndex: pi, type: type) != nil
        else { return false }
        // 해당 스코어만 부분 로드
        loadScoreData(at: si)
        // 새로 추가된 페이지로 flat 인덱스 갱신
        selectedPageIndex = flat + 1
        return true
    }
    
    // TODO: 나중에 페이지 이동 구현시 사용
    func movePage(score: Content, from source: IndexSet, to destination: Int) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: score) else { return }
        var pages = ScorePageManager.shared.fetchPages(for: detail)
        pages.move(fromOffsets: source, toOffset: destination)
        
        DispatchQueue.global(qos: .userInitiated).async {
            ScorePageManager.shared.updateScorePageDisplayOrder(pages)
            
            DispatchQueue.main.async {
                self.loadAllScoresData()
            }
        }
    }
    
    /// flatPages의 index에 해당하는 페이지를 삭제
    func deletePage(atFlatIndex flat: Int) {
        guard let (si, pi) = splitFlatIndex(flat),
              let detail = ScoreDetailManager.shared.fetchDetail(for: scores[si])
        else { return }
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        guard pages.indices.contains(pi),
              ScorePageManager.shared.deletePage(pages[pi])
        else { return }
        loadScoreData(at: si)
        // 삭제 후에도 flat 인덱스가 범위 내에 있도록 클램프
        selectedPageIndex = min(flat, flatPages.count - 1)
    }
    
    /// flatPages의 index에 해당하는 페이지를 회전
    func rotatePage(atFlatIndex flat: Int, clockwise: Bool) {
        guard let (si, pi) = splitFlatIndex(flat),
              let detail = ScoreDetailManager.shared.fetchDetail(for: scores[si])
        else { return }
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        guard pages.indices.contains(pi),
              ScorePageManager.shared.rotatePage(pages[pi], clockwise: clockwise)
        else { return }
        loadScoreData(at: si)
    }
    
    /// flatPages의 index에 해당하는 페이지를 복제
    func duplicatePage(atFlatIndex flat: Int) {
        guard let (si, pi) = splitFlatIndex(flat),
              let detail = ScoreDetailManager.shared.fetchDetail(for: scores[si])
        else { return }
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        guard pages.indices.contains(pi),
              let newPage = ScorePageManager.shared.clonePage(pages[pi])
        else { return }
        // 필기·코드 복제
        let anns = ScoreAnnotationManager.shared.fetchAnnotations(for: pages[pi])
        ScoreAnnotationManager.shared.cloneAnnotations(anns, to: newPage)
        let chords = ScoreChordManager.shared.fetchChords(for: pages[pi])
        ScoreChordManager.shared.cloneChords(chords, to: newPage)
        loadScoreData(at: si)
        // 복제된 페이지로 이동
        selectedPageIndex = flat + 1
    }
    
    func saveAnnotations() {
        guard selectedPageIndex < flatPages.count else { return }
        // flat 인덱스 → (scoreIndex, pageIndex) 로 변환
        guard let (scoreIdx, pageIdx) = splitFlatIndex(selectedPageIndex) else { return }
        let scoreContent = scores[scoreIdx]

        // Core Data의 ScorePage 엔티티와 매핑된 로컬 인덱스 페이지
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: scoreContent) else { return }
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        guard pages.indices.contains(pageIdx) else { return }

        // 현재 탭에 표시된 drawing (flat 인덱스로 관리)
        let drawing = scoreAnnotationViewModel.pageDrawings[selectedPageIndex]

        // 해당 페이지 하나만 저장
        _ = ScoreAnnotationManager.shared.saveAnnotation(drawing: drawing, for: pages[pageIdx])
      }
    
    func resetChords(completion: (() -> Void)? = nil) {
        // 현재 flat index 기준으로 해당 스코어만 reset
        DispatchQueue.global(qos: .userInitiated).async {
            guard let (si, _) = self.splitFlatIndex(self.selectedPageIndex) else {
                DispatchQueue.main.async { completion?() }
                return
            }
            let score = self.scores[si]
            guard let detail = ScoreDetailManager.shared.fetchDetail(for: score) else {
                DispatchQueue.main.async { completion?() }
                return
            }
            let pages = ScorePageManager.shared.fetchPages(for: detail)
            for page in pages {
                let chords = ScoreChordManager.shared.fetchChords(for: page)
                ScoreChordManager.shared.deleteChords(chords)
            }
            detail.key = nil
            detail.t_key = nil
            
            DispatchQueue.main.async {
                // 해당 스코어만 부분 로드
                self.loadScoreData(at: si)
                completion?()
            }
        }
    }
}


