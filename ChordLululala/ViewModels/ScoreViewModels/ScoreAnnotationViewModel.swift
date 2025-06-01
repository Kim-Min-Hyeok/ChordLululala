//////
//////  ScoreAnnotationViewModel.swift
//////  ChordLululala
//////
//////  Created by 김민준 on 5/4/25.
//////
////
import SwiftUI
import PencilKit
import Combine
import CoreData

final class ScoreAnnotationViewModel: ObservableObject {
    @Published var currentDrawing: PKDrawing = PKDrawing()
    @Published var isEditing: Bool = false
    
    // 페이지별 필기 데이터를 저장할 배열
    @Published var pageDrawings: [UUID: PKDrawing] = [:]
    @Published var pageModels: [ScorePageModel] = [] /// 페이지별로 저장하기 위해 배열로 저장
    
    private let annotationManager = ScoreAnnotationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(content: ContentModel?) {
        print("▶️ [ViewModel.init] initializing with content:", content?.cid ?? "nil")
        
        if let content = content,
           let detail = ScoreDetailManager.shared.fetchScoreDetailModel(for: content) {
            // ScoreDetail에서 모든 페이지 모델 가져오기
            self.pageModels = ScorePageManager.shared.fetchPageModels(for: detail)
            print("📚 [ViewModel.init] loaded \(self.pageModels.count) pages")
            
            // 각 페이지의 필기 데이터 로드
            for pageModel in pageModels {
                load(for: pageModel)
            }
        }
        
        setupAutoSave()
    }
    
    private func setupAutoSave() {
        // 필기가 바뀌면 1초 디바운스 저장
        $currentDrawing
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] drawing in
                guard let self = self,
                      let currentPageModel = self.pageModels.first(where: { $0.s_pid == self.currentPageId }) else { return }
                print("🔄 [AutoSave] currentDrawing changed, saving...")
                self.save(for: currentPageModel)
            }
            .store(in: &cancellables)
        
        $isEditing
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self,
                      let currentPageModel = self.pageModels.first(where: { $0.s_pid == self.currentPageId }) else { return }
                print("🔒 [AutoSave] editing ended, saving...")
                self.save(for: currentPageModel)
            }
            .store(in: &cancellables)
    }
    
    // 현재 페이지 ID
    var currentPageId: UUID?
    
    // 현재 페이지 변경 시 호출
    func switchToPage(pageId: UUID) {
        currentPageId = pageId
        if let drawing = pageDrawings[pageId] {
            currentDrawing = drawing
        } else {
            currentDrawing = PKDrawing()
        }
    }
    
    func load(for pageModel: ScorePageModel) {
        print("▶️ [ViewModel.load] fetching annotations for pageID:", pageModel.s_pid)
        let models = annotationManager.fetch(for: pageModel)
        if let first = models.first,
           let drawing = try? PKDrawing(data: first.strokeData) {
            print("✅ [ViewModel.load] Loaded annotation for page:", pageModel.s_pid)
            pageDrawings[pageModel.s_pid] = drawing
        } else {
            print("⚠️ [ViewModel.load] No annotation found for page:", pageModel.s_pid)
            pageDrawings[pageModel.s_pid] = PKDrawing()
        }
    }
    
    func save(for pageModel: ScorePageModel) {
        let data = currentDrawing.dataRepresentation()
        let annotation = ScoreAnnotationModel(s_aid: pageModel.s_pid, strokeData: data)
        print("▶️ [ViewModel.save] saving annotation for pageID:", pageModel.s_pid)
        annotationManager.save(annotations: [annotation], for: pageModel)
        pageDrawings[pageModel.s_pid] = currentDrawing
    }
}
