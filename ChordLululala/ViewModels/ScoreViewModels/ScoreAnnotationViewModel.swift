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
    
    init(content: Content) {
        load(content)
    }
    
    func load(_ content: Content) {
        guard let detailEntity = ScoreDetailManager.shared.fetchDetail(for: content) else {
            print("❌ load: ScoreDetail 엔티티를 찾을 수 없음")
            return
        }
        
        // 2) 해당 detail에 속한 ScorePage 엔티티들 페치(정렬 포함)
        let pageEntities = ScorePageManager.shared.fetchPages(for: detailEntity)
        
        // 3) 페이지별 PKDrawing 복원
        pageDrawings = pageEntities.map { page in
            // 3-a) NSSet → Set<ScoreAnnotation> → Array 로 언래핑
            let annotationEntities = (page.scoreAnnotations as? Set<ScoreAnnotation>) ?? []
            
            // 3-b) 빈 drawing 생성 후, 각 annotation의 strokeData를 append
            var drawing = PKDrawing()
            annotationEntities.forEach { annot in
                if let data = annot.strokeData,
                   let stroke = try? PKDrawing(data: data) {
                    drawing.append(stroke)
                }
            }
            return drawing
        }
    }

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
