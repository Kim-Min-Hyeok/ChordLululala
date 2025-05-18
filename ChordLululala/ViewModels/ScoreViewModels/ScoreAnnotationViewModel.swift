////
////  ScoreAnnotationViewModel.swift
////  ChordLululala
////
////  Created by 김민준 on 5/4/25.
////
//
import SwiftUI
import PencilKit
import Combine
import CoreData
//
//// 한 페이지 분량의 필기 데이터를 담는 모델
struct PageAnnotation {
    let page: Int
    var drawing: PKDrawing
    var storageId: UUID  // CoreData 에 저장할 때 쓰일 고유 식별자
}


final class ScoreAnnotationViewModel : ObservableObject {
    @Published var isEditing: Bool = false
    @Published var currentDrawing: PKDrawing = PKDrawing()
    
    var pageModel : ScorePageModel
    private let annotationManager = ScoreAnnotationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(pageModel: ScorePageModel){
        self.pageModel = pageModel
        setupAutoSave()
        load()
    }
    
    private func setupAutoSave(){
        $currentDrawing
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
        
        $isEditing
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    
    
    func load(){
        let models = annotationManager.fetch(for: pageModel)
        if let first = models.first,
           let drawing = try? PKDrawing(data: first.strokeData){
            print(#fileID,#function,#line, "불러오기 성공")
            currentDrawing = drawing
        } else {
            currentDrawing = PKDrawing()
        }
        
    }
    
    func save(){
        let data = currentDrawing.dataRepresentation()
        let annotation = ScoreAnnotationModel(s_aid: UUID(), strokeData: data)
        annotationManager.save(annotations: [annotation], for: pageModel)
    }
    
    
}
