//
//  ScoreSettingViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/23/25.
//

import Foundation

final class ScoreSettingViewModel: ObservableObject {
    @Published var isSetting : Bool = false
    
    func toggle(){
        isSetting.toggle()
    }
    
}
