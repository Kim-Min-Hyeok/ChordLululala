//
//  TermsOfServiceViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/23/25.
//

import SwiftUI
import Combine

class TermsOfServiceViewModel: ObservableObject {
    @Published var isPrivacyAgreed: Bool = false
    @Published var isServiceAgreed: Bool = false
    
    var isAllAgreed: Bool {
        get {
            isPrivacyAgreed && isServiceAgreed
        }
        set {
            isPrivacyAgreed = newValue
            isServiceAgreed = newValue
        }
    }
}
