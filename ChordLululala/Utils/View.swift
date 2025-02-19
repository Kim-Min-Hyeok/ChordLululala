//
//  View.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

#if canImport(UIKit)
import UIKit
import SwiftUICore
#endif

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
