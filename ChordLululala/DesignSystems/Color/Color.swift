//
//  Color.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/25/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Primary/Base
    static let primaryBaseBlack = Color(hex: "#000000")
    static let primaryBaseWhite = Color(hex: "#FFFFFF")
    
    // Primary/Gray
    static let primaryGray50  = Color(hex: "#F9FAFB")
    static let primaryGray100 = Color(hex: "#F3F4F6")
    static let primaryGray200 = Color(hex: "#E5E7EB")
    static let primaryGray300 = Color(hex: "#D2D5DA")
    static let primaryGray400 = Color(hex: "#9CA3AF")
    static let primaryGray500 = Color(hex: "#6D7280")
    static let primaryGray600 = Color(hex: "#4B5563")
    static let primaryGray700 = Color(hex: "#374151")
    static let primaryGray800 = Color(hex: "#1F2937")
    static let primaryGray900 = Color(hex: "#111827")
    
    // Primary/Blue
    static let primaryBlue50  = Color(hex: "#EFF6FF")
    static let primaryBlue100 = Color(hex: "#DBEAFE")
    static let primaryBlue200 = Color(hex: "#BFDBFE")
    static let primaryBlue300 = Color(hex: "#93C5FD")
    static let primaryBlue400 = Color(hex: "#60A5FA")
    static let primaryBlue500 = Color(hex: "#3B82F6")
    static let primaryBlue600 = Color(hex: "#2563EB")
    static let primaryBlue700 = Color(hex: "#1D4ED8")
    static let primaryBlue800 = Color(hex: "#1E40AF")
    static let primaryBlue900 = Color(hex: "#1E3A8A")
    
    // Supporting/Red
    static let supportingRed50  = Color(hex: "#FEF2F2")
    static let supportingRed100 = Color(hex: "#FEE2E2")
    static let supportingRed200 = Color(hex: "#FECACA")
    static let supportingRed300 = Color(hex: "#FCA5A5")
    static let supportingRed400 = Color(hex: "#FCA5A5") // 300과 동일한 값
    static let supportingRed500 = Color(hex: "#EF4444")
    static let supportingRed600 = Color(hex: "#DC2626")
    static let supportingRed700 = Color(hex: "#B91C1C")
    static let supportingRed800 = Color(hex: "#991B1B")
    static let supportingRed900 = Color(hex: "#7F1D1D")
    
    // Supporting/Yellow
    static let supportingYellow50  = Color(hex: "#FEFCE8")
    static let supportingYellow100 = Color(hex: "#FEF9C3")
    static let supportingYellow200 = Color(hex: "#FEF08A")
    static let supportingYellow300 = Color(hex: "#FDE047")
    static let supportingYellow400 = Color(hex: "#FACC15")
    static let supportingYellow500 = Color(hex: "#EAB308")
    static let supportingYellow600 = Color(hex: "#CA8A04")
    static let supportingYellow700 = Color(hex: "#A16207")
    static let supportingYellow800 = Color(hex: "#854D0E")
    static let supportingYellow900 = Color(hex: "#713F12")
    
    // Supporting/Green
    static let supportingGreen50  = Color(hex: "#F0FDF4")
    static let supportingGreen100 = Color(hex: "#DCFCE7")
    static let supportingGreen200 = Color(hex: "#BBF7D0")
    static let supportingGreen300 = Color(hex: "#86EFAC")
    static let supportingGreen400 = Color(hex: "#4ADE80")
    static let supportingGreen500 = Color(hex: "#22C55E")
    static let supportingGreen600 = Color(hex: "#16A34A")
    static let supportingGreen700 = Color(hex: "#15803D")
    static let supportingGreen800 = Color(hex: "#166534")
    static let supportingGreen900 = Color(hex: "#14532D")
}
