//
//  ScoreAnnotationViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/4/25.
//

import SwiftUI
import PencilKit
import Combine
import CoreData

// 한 페이지 분량의 필기 데이터를 담는 모델
struct PageAnnotation {
    let page: Int
    var drawing: PKDrawing
    var storageId: UUID  // CoreData 에 저장할 때 쓰일 고유 식별자
}

final class ScoreAnnotationViewModel: ObservableObject{
    @Published var isEditing: Bool = false
    @Published var currentDrawing: PKDrawing = PKDrawing()
    
    private let contentId: UUID
    private var annotations: [Int: PageAnnotation] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.context // CoreData를 위해 필요함
    
    init(contentId: UUID
    ) {
        self.contentId = contentId
        // 페이지가 바뀔 때마다 자동으로 저장 → 불러오기
        // (상위 VM 의 currentPage 퍼블리셔를 구독하세요)
    }
    
    /// 현재 페이지의 PKDrawing 을 저장하고 메모리 해제
        func save(page: Int) {
            guard let pageAnnot = annotations[page] else {
                // 새로 생성
                let newId = UUID()
                let model = PageAnnotation(page: page, drawing: currentDrawing, storageId: newId)
                annotations[page] = model
                persist(model)
                return
            }
            // 기존에 있던 ID 로 업데이트
            var updated = pageAnnot
            updated.drawing = currentDrawing
            annotations[page] = updated
            persist(updated)
        }
//    func save(page: Int){
//        let pa = annotations[page] ?? {
//            let newId = UUID()
//            let model = PageAnnotation(page: page,
//                                       drawing: currentDrawing,
//                                       storageId: newId)
//            annotations[page] = model
//            return model
//        }()
//        
//        persist(pa)
//    }
    
    
    
    /// 저장된 페이지가 있으면 로드, 아니면 빈 캔버스
    func load(page: Int) {
        if let pageAnnot = annotations[page] {
            currentDrawing = pageAnnot.drawing
        } else if let loaded = fetchFromStore(contentId: contentId, page: page) {
            annotations[page] = loaded
            currentDrawing = loaded.drawing
        } else {
            currentDrawing = PKDrawing()
        }
    }
    
    // MARK: - Persistence (예: CoreData 로직)
    private func persist(_ pa: PageAnnotation) {
        // CoreData 의 ScoreAnnotation 엔티티에
        // pa.storageId, contentId, pa.page, strokeData = pa.drawing.dataRepresentation() 저장
        
        
        
        
        
        
    }
    
    private func fetchFromStore(contentId: UUID, page: Int) -> PageAnnotation? {
        // CoreData 에서 contentId & page 로 조회해서
        // ScoreAnnotationModel(s_aid, strokeData) 가져오고
        // PKDrawing(data: strokeData) 로 복원
        // return PageAnnotation(page: page, drawing: drawing, storageId: s_aid)
        return nil
    }
}




