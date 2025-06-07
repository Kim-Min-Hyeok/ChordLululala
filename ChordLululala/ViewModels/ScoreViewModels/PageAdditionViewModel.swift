//
//  PageAdditionViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/6/25.
//

import SwiftUI
import CoreData

enum PageType{
    case blank // 빈종이
    case staff // 오선지
}

final class PageAdditionViewModel: ObservableObject{
    @Published var isSheetPresented: Bool = false
    @Published var isBlankPage: Bool = true
    
    private let pdfViewModel: ScorePDFViewModel
    private let pageNavViewModel: PageNavigationViewModel
    private var content: ContentModel?
    
    private let pageManager = ScorePageManager.shared
    private let detailManager = ScoreDetailManager.shared
    
    init(pdfViewModel: ScorePDFViewModel, pageNavViewModel: PageNavigationViewModel){
        self.pdfViewModel = pdfViewModel
        self.pageNavViewModel = pageNavViewModel
    }
    
    
    /// Content 설정
    func setContent(_ content: ContentModel?){
        self.content = content
    }
    
    /// “페이지 추가” 버튼 눌렀을 때 호출
    func presentSheet() {
        isSheetPresented = true
        print("페이지 추가 버튼 눌림")
    }
    
    /// 모달에서 선택된 타입으로 실제 페이지 추가
    func addPage(_ type: PageType) {
        
        guard let content = content else {
            print(#fileID,#function,#line, "content 없음")
            isSheetPresented = false
            return
        }
        
        //ScoreDetail 가져오기
        let scoreDetail: ScoreDetailModel
        if let existing  = detailManager.fetchScoreDetailModel(for: content) {
            scoreDetail = existing
        } else {
            guard let created = createScoreDetailSync(for: content) else {
                print(#fileID,#function,#line, "❌ ScoreDetail 생성 실패")
                isSheetPresented = false
                return
            }
            scoreDetail = created
        }
        
        
        let currentIndex = pageNavViewModel.currentPage
        pdfViewModel.addPageNextIndex(type, afterIndex: currentIndex)
        
        if let newPageModel = pageManager.addPage(for: scoreDetail, afterIndex: currentIndex, type: type) {
            print("✅ 페이지 추가 완료: \(type), 페이지 ID: \(newPageModel.s_pid)")
            
        } else {
            print("❌ CoreData 페이지 저장 실패")
        }
        
        isSheetPresented = false
    }
    
    
    /// ScoreDetail 없을 경우 생성
    private func createScoreDetailSync(for content: ContentModel) -> ScoreDetailModel? {
        let req: NSFetchRequest<Content> = Content.fetchRequest()
        req.predicate = NSPredicate(format: "cid == %@", content.cid as CVarArg)
        
        do {
            guard let contentEntity = try CoreDataManager.shared.context.fetch(req).first else {
                print(#fileID,#function,#line, "Content 앤티티 찾을 수 없음")
                return nil
            }
            
            let detailEntity = ScoreDetail(context: CoreDataManager.shared.context)
            detailEntity.s_did = UUID()
            detailEntity.key = ""
            detailEntity.t_key = ""
            contentEntity.scoreDetail = detailEntity
            
            try CoreDataManager.shared.context.save()
            return ScoreDetailModel(entity: detailEntity)
        } catch {
            print(#fileID,#function,#line, "ScoreDetail 생성 실패")
            return nil
        }
    }
    
    
}
