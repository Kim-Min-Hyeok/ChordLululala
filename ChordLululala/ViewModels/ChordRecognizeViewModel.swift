//
//  ChordRecognizeViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import SwiftUI
import Combine

final class ChordRecognizeViewModel: ObservableObject {
    @Published var pagesImages: [UIImage] = []
    @Published var pageModels: [ScorePageModel] = []
    @Published var chordLists: [[ScoreChordModel]] = []
    @Published var doneCount: Int = 0
    @Published var totalCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Content → ScoreDetail → 기존 ScorePageModel → ScoreChord 인식 & 저장
    func startRecognition(for file: ContentModel) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: file),
              let pdfURL  = ScoreDetailManager.shared.getContentURL(for: detail)
        else {
            print("⚠️ Missing ScoreDetail or PDF URL for Content \(file.cid)")
            return
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
}
