//
//  ScorePageOverViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import Foundation


final class ScorePageOverViewModel: ObservableObject {
    @Published var isPageOver: Bool = false
    
    
    func toggle(){
        isPageOver.toggle()
    }
    
    
    
}
