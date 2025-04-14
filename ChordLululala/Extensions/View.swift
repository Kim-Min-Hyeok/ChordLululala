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
    
    @ViewBuilder
    func conditionalContextMenu<Content: View>(
        isEnabled: Bool,
        @ViewBuilder menuItems: () -> Content
    ) -> some View {
        if isEnabled {
            self.contextMenu(menuItems: menuItems)
        } else {
            self
        }
    }
}
