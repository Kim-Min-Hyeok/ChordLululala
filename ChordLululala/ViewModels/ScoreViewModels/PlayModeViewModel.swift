//
//  PlayModeViewModel.swift
//  ChordLululala
//
//  Created by 김민준 on 5/2/25.
//


import SwiftUI
import Combine
 
/// 연주모드 관리 
final class PlayModeViewModel: ObservableObject{
    
    @Published var isOn : Bool = false
    func toggle(){
        isOn.toggle()
    }
    
    
}
