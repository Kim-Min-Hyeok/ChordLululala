//
//  ScoreAnnotationViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/9/25.
//

import SwiftUI
import Combine
import PencilKit

final class ScoreAnnotationViewModel: ObservableObject {
    // pageDrawings는 PKDrawing 단위로 바인딩 시 사용
    @Published var pageDrawings: [PKDrawing] = []
    private var tempDrawings = Set<Int>()
    
    private var cancellables = Set<AnyCancellable>()

    func updateDrawing(_ drawing: PKDrawing, forPage index: Int) {
            guard pageDrawings.indices.contains(index) else { return }
            // 1) 화면용 drawing 배열만 갱신
            pageDrawings[index] = drawing
            // 2) 이 페이지는 나중에 saveAll 때 저장해야 할 대상임을 표시
            tempDrawings.insert(index)
        }
    
    func saveAll(for content: Content) {
        guard let detail = ScoreDetailManager.shared.fetchDetail(for: content) else { return }
        let pages = ScorePageManager.shared.fetchPages(for: detail)
        for idx in tempDrawings where idx < pages.count {
            let page = pages[idx]
            let drawing = pageDrawings[idx]
            _ = ScoreAnnotationManager.shared.saveAnnotation(drawing: drawing, for: page)
        }
        tempDrawings.removeAll()
    }
}
