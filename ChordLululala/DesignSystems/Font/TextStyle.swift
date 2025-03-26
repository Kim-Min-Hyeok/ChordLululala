//
//  TextStyle.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/24/25.
//

import SwiftUI

struct TextStyle {
    let font: Font
    let size: CGFloat
    let lineHeightMultiplier: CGFloat
    let letterSpacing: CGFloat
    
    var additionalLineSpacing: CGFloat {
        return size * (lineHeightMultiplier - 1)
    }
}

extension TextStyle {
    // MARK: - Display XL (24pt)
    static let displayXLBold = TextStyle(font: .displayXLBold, size: 24, lineHeightMultiplier: 1.4, letterSpacing: 24 * -0.0035)
    static let displayXLSemiBold = TextStyle(font: .displayXLSemiBold, size: 24, lineHeightMultiplier: 1.4, letterSpacing: 24 * -0.0035)
    static let displayXLMedium = TextStyle(font: .displayXLMedium, size: 24, lineHeightMultiplier: 1.4, letterSpacing: 24 * -0.0035)
    static let displayXLRegular = TextStyle(font: .displayXLRegular, size: 24, lineHeightMultiplier: 1.4, letterSpacing: 24 * -0.0035)
    
    // MARK: - Heading XL (18pt)
    static let headingXLBold = TextStyle(font: .headingXLBold, size: 18, lineHeightMultiplier: 1.4, letterSpacing: 18 * -0.0035)
    static let headingXLSemiBold = TextStyle(font: .headingXLSemiBold, size: 18, lineHeightMultiplier: 1.4, letterSpacing: 18 * -0.0035)
    static let headingXLMedium = TextStyle(font: .headingXLMedium, size: 18, lineHeightMultiplier: 1.4, letterSpacing: 18 * -0.0035)
    static let headingXLRegular = TextStyle(font: .headingXLRegular, size: 18, lineHeightMultiplier: 1.4, letterSpacing: 18 * -0.0035)
    
    // MARK: - Heading Lg (17pt)
    static let headingLgBold = TextStyle(font: .headingLgBold, size: 17, lineHeightMultiplier: 1.4, letterSpacing: 17 * -0.0035)
    static let headingLgSemiBold = TextStyle(font: .headingLgSemiBold, size: 17, lineHeightMultiplier: 1.4, letterSpacing: 17 * -0.0035)
    static let headingLgMedium = TextStyle(font: .headingLgMedium, size: 17, lineHeightMultiplier: 1.4, letterSpacing: 17 * -0.0035)
    static let headingLgRegular = TextStyle(font: .headingLgRegular, size: 17, lineHeightMultiplier: 1.4, letterSpacing: 17 * -0.0035)
    
    // MARK: - Heading Md (16pt)
    static let headingMdBold = TextStyle(font: .headingMdBold, size: 16, lineHeightMultiplier: 1.4, letterSpacing: 16 * -0.0035)
    static let headingMdSemiBold = TextStyle(font: .headingMdSemiBold, size: 16, lineHeightMultiplier: 1.4, letterSpacing: 16 * -0.0035)
    static let headingMdMedium = TextStyle(font: .headingMdMedium, size: 16, lineHeightMultiplier: 1.4, letterSpacing: 16 * -0.0035)
    static let headingMdRegular = TextStyle(font: .headingMdRegular, size: 16, lineHeightMultiplier: 1.4, letterSpacing: 16 * -0.0035)
    
    // MARK: - Heading Sm (15pt)
    static let headingSmBold = TextStyle(font: .headingSmBold, size: 15, lineHeightMultiplier: 1.4, letterSpacing: 15 * -0.0035)
    static let headingSmSemiBold = TextStyle(font: .headingSmSemiBold, size: 15, lineHeightMultiplier: 1.4, letterSpacing: 15 * -0.0035)
    static let headingSmMedium = TextStyle(font: .headingSmMedium, size: 15, lineHeightMultiplier: 1.4, letterSpacing: 15 * -0.0035)
    static let headingSmRegular = TextStyle(font: .headingSmRegular, size: 15, lineHeightMultiplier: 1.4, letterSpacing: 15 * -0.0035)
    
    // MARK: - Body Text XL (14pt)
    static let bodyTextXLBold = TextStyle(font: .bodyTextXLBold, size: 14, lineHeightMultiplier: 1.4, letterSpacing: 14 * -0.0035)
    static let bodyTextXLSemiBold = TextStyle(font: .bodyTextXLSemiBold, size: 14, lineHeightMultiplier: 1.4, letterSpacing: 14 * -0.0035)
    static let bodyTextXLMedium = TextStyle(font: .bodyTextXLMedium, size: 14, lineHeightMultiplier: 1.4, letterSpacing: 14 * -0.0035)
    static let bodyTextXLRegular = TextStyle(font: .bodyTextXLRegular, size: 14, lineHeightMultiplier: 1.4, letterSpacing: 14 * -0.0035)
    
    // MARK: - Body Text Lg (13pt)
    static let bodyTextLgBold = TextStyle(font: .bodyTextLgBold, size: 13, lineHeightMultiplier: 1.4, letterSpacing: 13 * -0.0035)
    static let bodyTextLgSemiBold = TextStyle(font: .bodyTextLgSemiBold, size: 13, lineHeightMultiplier: 1.4, letterSpacing: 13 * -0.0035)
    static let bodyTextLgMedium = TextStyle(font: .bodyTextLgMedium, size: 13, lineHeightMultiplier: 1.4, letterSpacing: 13 * -0.0035)
    static let bodyTextLgRegular = TextStyle(font: .bodyTextLgRegular, size: 13, lineHeightMultiplier: 1.4, letterSpacing: 13 * -0.0035)
}
