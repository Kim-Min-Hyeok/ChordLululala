//
//  ChordRecognizeViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import SwiftUI
import Combine

enum RecognitionState {
    case recognition
    case keyFixing
    case chordFixing
    case keyTranspostion
}

final class ChordRecognizeViewModel: ObservableObject {
    @Published var state: RecognitionState = .recognition
    
    @Published var pagesImages: [UIImage] = []
    @Published var pageModels: [ScorePageModel] = []
    @Published var chordLists: [[ScoreChordModel]] = []
    @Published var doneCount: Int = 0
    @Published var totalCount: Int = 0
    
    @Published var key: String = "C"
    @Published var t_key: String = "C"
    @Published var transposeAmount: Int = 0
    @Published var isSharp: Bool = true
    
    @Published var selectedPage = 0
    @Published var editingChord: ScoreChordModel? = nil
    
    let sharpKeys: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7
    ]
    
    let flatKeys: [String: Int] = [
        "C": 0, "F": 1, "Bb": 2, "Eb": 3, "Ab": 4, "Db": 5, "Gb": 6, "Cb": 7
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Content → ScoreDetail → 기존 ScorePageModel → ScoreChord 인식 & 저장
    func startRecognition(for file: ContentModel) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: file),
              let pdfURL  = ScoreDetailManager.shared.getContentURL(for: detail)
        else {
            print("⚠️ Missing ScoreDetail or PDF URL for Content \(file.cid)")
            return
        }
        
        // 이미 코드 인식을 했으면 (이미 key 및 t_key가 존재하면 바로 chordFixing으로 이동)
        if !detail.key.isEmpty && !detail.t_key.isEmpty {
            self.state = .chordFixing

            DispatchQueue.main.async {
                self.key = detail.key
                self.t_key = detail.t_key
                self.isSharp = detail.isSharp

                // ✅ 수정된 부분
                if self.isSharp {
                    self.transposeAmount = self.sharpKeys[self.t_key] ?? 0
                } else {
                    self.transposeAmount = self.flatKeys[self.t_key] ?? 0
                }

                self.pageModels  = ScorePageManager.shared.fetchPageModels(for: detail)
                self.chordLists  = self.pageModels.map { ScoreChordManager.shared.fetch(for: $0) }
                self.pagesImages = PDFProcessor.extractPages(from: pdfURL)
                self.totalCount  = self.pageModels.count
                self.doneCount   = self.totalCount
            }
            print("✅ 이미 key 정보 존재: \(detail.key), \(detail.t_key)")
            return
        } else {
            print("⚠️ key 또는 t_key 비어 있음: key=\(detail.key), t_key=\(detail.t_key)")
        }
        
        // 1) 페이지 모델 + 이미지 준비
        let pModels = ScorePageManager.shared.fetchPageModels(for: detail)
        let imgs    = PDFProcessor.extractPages(from: pdfURL)
        
        DispatchQueue.main.async {
            self.pageModels  = pModels
            self.pagesImages = imgs
            self.chordLists  = Array(repeating: [], count: pModels.count)
            self.totalCount  = pModels.count
            self.doneCount   = 0
        }
        
        // 2) OCR & 저장 & 업데이트
        for (idx, image) in imgs.enumerated() {
            ChordRecognizeManager.shared
                .recognize(image: image)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] processed, chords in
                    guard let self = self else { return }
                    // CoreData 저장
                    ScoreChordManager.shared.save(chords: chords, for: self.pageModels[idx])
                    // ViewModel 반영
                    self.chordLists[idx] = chords
                    self.doneCount    += 1
                }
                .store(in: &cancellables)
        }
    }
    
    func findKey() {
        guard let firstPage = chordLists.first,
              let topLeftChord = firstPage.min(by: { ($0.x * $0.y) < ($1.x * $1.y) })
        else { return }
        
        let chord = topLeftChord.chord
        let pattern = "^[A-Ga-g][#♯b♭]?"
        let root: String
        
        if let match = chord.range(of: pattern, options: .regularExpression) {
            root = String(chord[match])
                .uppercased()
                .replacingOccurrences(of: "♯", with: "#")
                .replacingOccurrences(of: "♭", with: "b")
        } else {
            root = chord.uppercased()
        }
        
        key = root
        
        if let count = sharpKeys[root] {
            isSharp = true
            transposeAmount = count
        } else if let count = flatKeys[root] {
            isSharp = false
            transposeAmount = count
        } else {
            isSharp = true
            transposeAmount = 0
        }
        
        print("🎵 topLeftChord = \(topLeftChord.chord), position = (\(topLeftChord.x), \(topLeftChord.y))")
        
    }
    
    func fixingKey(for file: ContentModel) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: file) else { return }
        
        detail.key = key
        detail.t_key = t_key
        detail.isSharp = isSharp
        ScoreDetailManager.shared.update(detailModel: detail)
    }
    
    func applyTransposedKey(for file: ContentModel) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: file) else { return }
        detail.t_key = t_key
        detail.isSharp = isSharp
        ScoreDetailManager.shared.update(detailModel: detail)
    }
    
    func updateChordPosition(_ chord: ScoreChordModel, pageIndex: Int, newPos: CGPoint, imageSize: CGSize, displaySize: CGSize) {
        // 변환: 디스플레이 위치 → 원본 이미지 위치
        let newX = newPos.x * imageSize.width / displaySize.width
        let newY = newPos.y * imageSize.height / displaySize.height
        
        if let idx = chordLists[pageIndex].firstIndex(where: { $0.s_cid == chord.s_cid }) {
            chordLists[pageIndex][idx].x = Double(Int(newX))
            chordLists[pageIndex][idx].y = Double(Int(newY))
        }
    }
    
    func deleteChord(_ chord: ScoreChordModel, pageIndex: Int) {
        chordLists[pageIndex].removeAll { $0.s_cid == chord.s_cid }
    }
    
    func addNewChord(text: String, to pageIndex: Int, position: CGPoint) {
        // 역변환: 현재 t_key 기준으로 입력된 text를 원래 key 기준으로 되돌림
        let originalChord = reverseTransposedChord(for: text)
        
        let newChord = ScoreChordModel(
            s_cid: UUID(),
            chord: originalChord,
            x: Double(position.x),
            y: Double(position.y),
            width: 60,
            height: 24
        )
        chordLists[pageIndex].append(newChord)
    }
    
    func finalizeChordRecognition(completion: @escaping () -> Void) {
        for (idx, chords) in chordLists.enumerated() {
            let pageModel = pageModels[idx]
            ScoreChordManager.shared.save(chords: chords, for: pageModel)
        }
        completion()
    }
    
    func transposedChord(for original: String) -> String {
        guard key != t_key else { return original }

        // 12음계는 고정
        let semitoneMap = ["C", "C#", "D", "D#", "E", "F",
                           "F#", "G", "G#", "A", "A#", "B"]
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
            // "Abm7" → "Ab"
            let candidates = enharmonicMap.keys.filter { chord.starts(with: $0) }
            guard let match = candidates.max(by: { $0.count < $1.count }),
                  let index = enharmonicMap[match] else { return nil }
            return (index, match)
        }

        guard let from = enharmonicMap[key],
              let to   = enharmonicMap[t_key] else { return original }

        let diff = (to - from + 12) % 12

        if let (idx, matched) = rootIndex(of: original) {
            let displayMap = isSharp ? displayMapSharp : displayMapFlat
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

        if let (idx, matched) = rootIndex(of: transposed) {
            let displayMap = isSharp ? displayMapSharp : displayMapFlat
            let newRoot = displayMap[(idx + diff) % 12]
            let suffix = transposed.dropFirst(matched.count)
            return newRoot + suffix
        }

        return transposed
    }
}
