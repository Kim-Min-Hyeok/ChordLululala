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
    @Published var annotationsForPages: [[ScoreAnnotationModel]] = []
    
    // pageDrawings는 PKDrawing 단위로 바인딩 시 사용
    @Published var pageDrawings: [PKDrawing] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel) {
        load(content)
    }
    
    func load(_ content: ContentModel) { 
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else { return }
        
        let pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
        annotationsForPages = pageModels.map { ScoreAnnotationManager.shared.fetch(for: $0) }
        
        // PKDrawing 복원
        pageDrawings = annotationsForPages.map { annotations in
            let drawing = PKDrawing()
            return annotations.reduce(into: drawing) { result, model in
                if let stroke = try? PKDrawing(data: model.strokeData) {
                    result = result.appending(stroke)
                }
            }
        }
    }

    func updateDrawing(_ drawing: PKDrawing, forPage index: Int) {
        guard annotationsForPages.indices.contains(index) else { return }
        let model = ScoreAnnotationModel(strokeData: drawing.dataRepresentation())
        annotationsForPages[index] = [model]
        pageDrawings[index] = drawing
    }
    
    func saveAll(for content: ContentModel) {
        guard let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) else { return }
        let pages = ScorePageManager.shared.fetchPageModels(for: detail)
        
        for (index, page) in pages.enumerated() where index < annotationsForPages.count {
            ScoreAnnotationManager.shared.save(annotations: annotationsForPages[index], for: page)
        }
    }
}
