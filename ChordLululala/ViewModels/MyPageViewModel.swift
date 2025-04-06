//
//  MyPageViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/29/25.
//

import SwiftUI
import Combine

class MyPageViewModel: ObservableObject {
//    @Published var user: UserModel? = nil
    @Published var selectedLanguage: String = "한국어"
    
    let availableLanguages = ["한국어", "영어"]
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
    }
}
