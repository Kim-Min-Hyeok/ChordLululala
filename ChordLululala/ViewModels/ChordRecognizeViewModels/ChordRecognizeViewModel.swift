//
//  ChordRecognizeViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import SwiftUI
import Combine
import CoreData

enum RecognitionState {
    case recognition
    case keyFixing
    case chordFixing
    case keyTranspostion
    //    case keyFixingAndTransposition
}

final class ChordRecognizeViewModel: ObservableObject {
    @Published var state: RecognitionState = .recognition
    
    @Published var pagesImages: [UIImage] = []
    @Published var scorePages: [ScorePage] = []
    @Published var scoreChords: [[ScoreChord]] = []
    @Published var doneCount: Int = 0
    @Published var totalCount: Int = 0
    
    @Published var key: String = "C"
    @Published var t_key: String = "C"
    @Published var transposeAmount: Int = 0
    @Published var isSharp: Bool = true
    
    @Published var selectedPage = 0
    @Published var editingChord: ScoreChord? = nil
    @Published var highlightedChordIDs: Set<NSManagedObjectID> = []
    
    // 키 인식되면, 바로 모달띄워야 하므로 viewModel로 관리
    @Published var showKeyTranspositionModal: Bool = false
    
    private let useMLKit: Bool = false  //TODO: 나중에 지우기, 키변환 인식 성능 개선 테스트 용
//    private let useMLKit: Bool = true
    
    let sharpKeys: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7
    ]
    
    let flatKeys: [String: Int] = [
        "C": 0, "F": 1, "Bb": 2, "Eb": 3, "Ab": 4, "Db": 5, "Gb": 6, "B": 7
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Content → ScoreDetail → 기존 ScorePageModel → ScoreChord 인식 & 저장
    func startRecognition(for file: Content) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: file),
              let pdfURL  = ScoreDetailManager.shared.getContentURL(for: detail)
        else {
            print("⚠️ Missing ScoreDetail or PDF URL for Content \(file.objectID)")
            return
        }
        
        // 이미 코드 인식을 했으면 (이미 key 및 t_key가 존재하면 바로 chordFixing으로 이동)
        if let key = detail.key, !key.isEmpty,
           let t_key = detail.t_key, !t_key.isEmpty
        {
            DispatchQueue.main.async {
                self.key = key
                self.t_key = t_key
                self.isSharp = self.sharpKeys.keys.contains(t_key)
                
                if self.isSharp {
                    self.transposeAmount = self.sharpKeys[self.t_key] ?? 0
                } else {
                    self.transposeAmount = self.flatKeys[self.t_key] ?? 0
                }
                
                self.scorePages  = ScorePageManager.shared.fetchPages(for: detail)
                self.scoreChords  = self.scorePages.map { ScoreChordManager.shared.fetchChords(for: $0) }
                self.pagesImages = PDFProcessor.extractPages(from: pdfURL)
                self.totalCount  = self.scorePages.count
                self.doneCount   = self.totalCount
                
                // MARK: Plan B Start
                self.state = .keyTranspostion
                self.showKeyTranspositionModal = true
                // MARK: Plan B End
                // MARK: Plan A Start
                //            self.state = .keyFixingAndTransposition
                // MARK: Plan A End
            }
            print("✅ 이미 key 정보 존재: \(String(describing: detail.key)), \(String(describing: detail.t_key))")
            
            return
        } else {
            print("⚠️ key 또는 t_key 비어 있음: key=\(String(describing: detail.key)), t_key=\(String(describing: detail.t_key))")
        }
        
        let allPages = ScorePageManager.shared.fetchPages(for: detail)
        let pdfPages = allPages.filter { $0.pageType == "pdf" }
        let images = PDFProcessor.extractPages(from: pdfURL)  // index: 0 ~ n-1
        
        // 1. originalPageIndex 기준 정렬 (PDF 순서 기준)
        let sortedPages = pdfPages.sorted { ($0.originalPageIndex) < ($1.originalPageIndex) }
        
        // 2. 매핑 가능한 범위만큼만 사용
        let minCount = min(images.count, sortedPages.count)
        let pagesToUse = Array(sortedPages.prefix(minCount))
        let imagesToUse = Array(images.prefix(minCount))
        
        DispatchQueue.main.async {
            self.scorePages = pagesToUse
            self.pagesImages = imagesToUse
            self.scoreChords = Array(repeating: [], count: minCount)
            self.totalCount = minCount
            self.doneCount = 0
        }
        
        // 3. OCR 수행 시도
        for idx in 0..<minCount {
            let pageEntity = pagesToUse[idx]
            let image = imagesToUse[idx]
            
            let recognizer: AnyPublisher<(UIImage, [RecognizedChord]), Never>
            if useMLKit {
                recognizer = MLKitChordRecognizeManager.shared.recognize(image: image)
            } else {
                recognizer = ChordRecognizeManager.shared.recognize(image: image)
            }
            
//            ChordRecognizeManager.shared
            recognizer
                .timeout(.seconds(3), scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] processedImage, recognizedChords in
                        guard let self = self else { return }
                        
                        let chordEntities = recognizedChords.map { rc -> ScoreChord in
                            let ent = ScoreChord(context: CoreDataManager.shared.context)
                            ent.chord     = rc.text
                            ent.x         = Double(rc.rect.origin.x)
                            ent.y         = Double(rc.rect.origin.y)
                            ent.width     = Double(rc.rect.width)
                            ent.height    = Double(rc.rect.height)
                            ent.scorePage = pageEntity
                            return ent
                        }
                        
                        ScoreChordManager.shared.save(chords: chordEntities, for: pageEntity)
                        self.scoreChords[idx] = chordEntities
                        self.doneCount += 1
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func extractRoot(from chord: String) -> String {
        let scalars = chord.unicodeScalars
        guard let first = scalars.first,
              CharacterSet(charactersIn: "A-Za-z").contains(first) else {
            return chord.uppercased()
        }
        // A~G + optional #/b/♯/♭
        let valid = CharacterSet(charactersIn: "ABCDEFGabcdefg#b♯♭")
        let rootScalars = scalars.prefix { valid.contains($0) }
        return String(rootScalars)
            .uppercased()
            .replacingOccurrences(of: "♯", with: "#")
            .replacingOccurrences(of: "♭", with: "b")
    }
    
    func findKey() {
        // 1) 첫 페이지의 코드 배열이 있고 비어있지 않은지
        guard let chords = scoreChords.first, !chords.isEmpty else { return }
        
        // 2) 화면 상단(작은 y) → 왼쪽(작은 x) 순으로 top-left 찾기
        let topLeft = chords.min { a, b in
            if a.y != b.y { return a.y < b.y }
            return a.x < b.x
        }!
        
        // 3) 루트만 추출
        let root = extractRoot(from: topLeft.chord ?? "C")
        let validKeys = ["C","G","D","A","E","B","F#","C#","Bb","Eb","Ab","Db","Gb"]
        let finalKey = validKeys.contains(root) ? root : "C"
        key = finalKey
        
        // 4) 전조량 결정
        if let cnt = sharpKeys[root] {
            isSharp         = true
            transposeAmount = cnt
        } else if let cnt = flatKeys[root] {
            isSharp         = false
            transposeAmount = cnt
        } else {
            // 기본값
            isSharp         = true
            transposeAmount = 0
        }
        
        print("🎵 topLeftChord = \(String(describing: topLeft.chord)), position = (\(topLeft.x), \(topLeft.y)), root = \(root)")
    }
    
    func fixingKey(for file: Content) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: file) else { return }
        
        detail.key = key
        detail.t_key = t_key
        isSharp = sharpKeys.keys.contains(t_key)
        ScoreDetailManager.shared.save(detailEntity: detail)
    }
    
    func applyTransposedKey(for file: Content) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: file) else { return }
        detail.t_key = t_key
        isSharp = sharpKeys.keys.contains(t_key)
        ScoreDetailManager.shared.save(detailEntity: detail)
    }
    
    func updateChordPosition(_ chord: ScoreChord, pageIndex: Int, newPos: CGPoint, imageSize: CGSize, displaySize: CGSize) {
        // 변환: 디스플레이 위치 → 원본 이미지 위치
        let newX = newPos.x * imageSize.width / displaySize.width
        let newY = newPos.y * imageSize.height / displaySize.height
        
        if let idx = scoreChords[pageIndex].firstIndex(where: { $0.objectID == chord.objectID }) {
            scoreChords[pageIndex][idx].x = Double(Int(newX))
            scoreChords[pageIndex][idx].y = Double(Int(newY))
        }
    }
    
    func deleteChord(_ chord: ScoreChord, pageIndex: Int) {
        scoreChords[pageIndex].removeAll { $0.objectID == chord.objectID }
    }
    
    func updateChord(editing: ScoreChord, newText: String) {
        // 1) 해당 페이지에서 index 찾기
        guard let idx = scoreChords[selectedPage]
            .firstIndex(where: { $0.objectID == editing.objectID })
        else { return }
        // 2) 배열 수정
        scoreChords[selectedPage][idx].chord = newText
    }
    
    func addNewChord(text: String, to pageIndex: Int, position: CGPoint) {
        let original = reverseTransposedChord(for: text)
        let scorePage = scorePages[pageIndex]
        
        guard let context = scorePage.managedObjectContext else {
            print("⚠️ scorePage에 context 없음")
            return
        }
        
        let chordEnt = ScoreChord(context: context)
        chordEnt.chord = original
        chordEnt.x = Double(position.x)
        chordEnt.y = Double(position.y)
        chordEnt.width = 60
        chordEnt.height = 24
        chordEnt.scorePage = scorePage
        
        scoreChords[pageIndex].append(chordEnt)
        markHighlight(for: chordEnt)
    }
    
    func addNewChordAtCenter(text: String, to pageIndex: Int) {
        guard pagesImages.indices.contains(pageIndex) else {
            addNewChord(text: text, to: pageIndex, position: CGPoint(x: 100, y: 100))
            return
        }
        let imgSize = pagesImages[pageIndex].size
        let centered = CGPoint(x: imgSize.width / 2 - 30, y: imgSize.height / 2 - 12)
        addNewChord(text: text, to: pageIndex, position: centered)
    }
    
    private func markHighlight(for chord: ScoreChord) {
        let id = chord.objectID
        highlightedChordIDs.insert(id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.highlightedChordIDs.remove(id)
        }
    }
    
    func finalizeChordRecognition(completion: @escaping () -> Void) {
        for (idx, chords) in scoreChords.enumerated() {
            let scorePage = scorePages[idx]
            ScoreChordManager.shared.save(chords: chords, for: scorePage)
        }
        completion()
    }
    
    func transposedChord(for original: String) -> String {
        guard key != t_key else { return original }
        
        let enharmonicMap: [String: Int] = [
            "C": 0, "B#": 0,
            "C#": 1, "Db": 1,
            "D": 2,
            "D#": 3, "Eb": 3,
            "E": 4, "Fb": 4,
            "F": 5, "E#": 5,
            "F#": 6, "Gb": 6,
            "G": 7,
            "G#": 8, "Ab": 8,
            "A": 9,
            "A#": 10, "Bb": 10,
            "B": 11, "Cb": 11
        ]
        
        let displayMapSharp = ["C", "C#", "D", "D#", "E", "F",
                               "F#", "G", "G#", "A", "A#", "B"]
        let displayMapFlat  = ["C", "Db", "D", "Eb", "E", "F",
                               "Gb", "G", "Ab", "A", "Bb", "B"]
        
        func rootIndex(of chord: String) -> (index: Int, matched: String)? {
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }
        
        guard let from = enharmonicMap[key],
              let to   = enharmonicMap[t_key] else { return original }
        
        let diff = (to - from + 12) % 12
        let useSharp = sharpKeys.keys.contains(t_key)
        
        if let (idx, matched) = rootIndex(of: original) {
            let displayMap = useSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = original.dropFirst(matched.count)
            return newRoot + suffix
        }
        
        return original
    }
    
    func reverseTransposedChord(for transposed: String) -> String {
        guard key != t_key else { return transposed }
        
        let enharmonicMap: [String: Int] = [
            "C": 0, "B#": 0,
            "C#": 1, "Db": 1,
            "D": 2,
            "D#": 3, "Eb": 3,
            "E": 4, "Fb": 4,
            "F": 5, "E#": 5,
            "F#": 6, "Gb": 6,
            "G": 7,
            "G#": 8, "Ab": 8,
            "A": 9,
            "A#": 10, "Bb": 10,
            "B": 11, "Cb": 11
        ]
        
        let displayMapSharp = ["C", "C#", "D", "D#", "E", "F",
                               "F#", "G", "G#", "A", "A#", "B"]
        let displayMapFlat  = ["C", "Db", "D", "Eb", "E", "F",
                               "Gb", "G", "Ab", "A", "Bb", "B"]
        
        func rootIndex(of chord: String) -> (index: Int, matched: String)? {
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }
        
        guard let from = enharmonicMap[t_key],
              let to   = enharmonicMap[key] else { return transposed }
        
        let diff = (to - from + 12) % 12
        let useSharp = sharpKeys.keys.contains(key)
        
        if let (idx, matched) = rootIndex(of: transposed) {
            let displayMap = useSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = transposed.dropFirst(matched.count)
            return newRoot + suffix
        }
        
        return transposed
    }
}
