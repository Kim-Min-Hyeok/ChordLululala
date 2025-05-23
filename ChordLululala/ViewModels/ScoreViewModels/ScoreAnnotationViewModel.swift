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

final class ScoreAnnotationViewModel : ObservableObject {
    @Published var currentDrawing: PKDrawing = PKDrawing()
    @Published var isEditing: Bool = false
    
    private let annotationManager = ScoreAnnotationManager.shared
    var pageModel : ScorePageModel
    private var cancellables = Set<AnyCancellable>()
    
    init(pageModel: ScorePageModel){
        self.pageModel = pageModel
        print("▶️ [ViewModel.init] for pageID:", pageModel.s_pid)           // 📍 init 호출 시점
        
        setupAutoSave()
        load()
    }
    
    private func setupAutoSave(){
        
        // 필기가 바뀌면 1초 디바운스 저장
        $currentDrawing
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("🔄 [AutoSave] currentDrawing changed, saving...")      // 📍 자동 저장 트리거
                self?.save()
            }
            .store(in: &cancellables)
        
        $isEditing
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in
                print("🔒 [AutoSave] editing ended, saving...")              // 📍 편집 종료 트리거
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    
    
    func load(){
        print("▶️ [ViewModel.load] fetching annotations for pageID:", pageModel.s_pid)  // 📍 load 호출
        let models = annotationManager.fetch(for: pageModel)
        if let first = models.first,
           let drawing = try? PKDrawing(data: first.strokeData){
            print("✅ [ViewModel.load] Loaded annotation (strokeData size:", first.strokeData.count, "bytes)")  // 📍 성공 로그
            currentDrawing = drawing
        } else {
            print("⚠️ [ViewModel.load] No annotation found, initializing blank")   // 📍 없음 로그
            currentDrawing = PKDrawing()
        }
        
    }
    
    func save(){
        let data = currentDrawing.dataRepresentation()
        let annotation = ScoreAnnotationModel(s_aid: pageModel.s_pid, strokeData: data)
        print("▶️ [ViewModel.save] saving annotation (data size:", data.count, "bytes) for pageID:", pageModel.s_pid)  // 📍 save 호출
        annotationManager.save(annotations: [annotation], for: pageModel)
    }
    
    
}
