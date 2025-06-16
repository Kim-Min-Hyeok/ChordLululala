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
        DispatchQueue.main.async { [weak self] in
            self?.pageDrawings[index] = drawing
            self?.tempDrawings.insert(index)
        }
    }
}
