//
//  ScoreSettingViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import Foundation

final class ScoreSettingViewModel: ObservableObject {
    @Published var isSetting : Bool = false
    @Published var isSinglePage : Bool = true
    
    
    func toggle(){
        isSetting.toggle()
    }
    
    
    func selectSinglePage(){
        isSinglePage = true
    }
    
    func selectMultiPage(){
        isSinglePage = false
    }
    
    
}
