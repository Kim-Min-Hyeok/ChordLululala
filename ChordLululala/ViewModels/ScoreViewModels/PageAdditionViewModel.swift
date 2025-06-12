//
//  PageAdditionViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/6/25.
//

import SwiftUI
import CoreData
import Combine

final class PageAdditionViewModel: ObservableObject{
    @Published var isBlankPage: Bool = true
    @Published var currentPage: Int = 0
    
    private var content: ContentModel?
    
    private let pageManager = ScorePageManager.shared
    private let detailManager = ScoreDetailManager.shared
    
    /// Content 설정
    func setContent(_ content: ContentModel?){
        self.content = content
    }
}
