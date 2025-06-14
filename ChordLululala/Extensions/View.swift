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

struct RoundedBorderShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    var lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let outerPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let innerRect = rect.insetBy(dx: lineWidth, dy: lineWidth)
        let innerPath = UIBezierPath(
            roundedRect: innerRect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius - lineWidth, height: radius - lineWidth)
        )
        let path = Path(outerPath.cgPath).subtracting(Path(innerPath.cgPath))
        return path
    }
}

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
