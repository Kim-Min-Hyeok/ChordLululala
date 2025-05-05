//
//  PlayModeViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/2/25.
//


import SwiftUI
import Combine
 
/// 코드 변환 클릭시 로딩뷰 띄워줌
final class IsTransposingViewModel: ObservableObject{
    
    @Published var isOn : Bool = false
    func toggle(){
        isOn.toggle()
    }
    
    
}

