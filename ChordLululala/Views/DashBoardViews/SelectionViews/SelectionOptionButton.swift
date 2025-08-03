//
//  SelectionOptionButton.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionOptionButton: View {
    let imageBaseName: String
    let title: String
    var action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    private var displayIconName: String {
        isEnabled ? imageBaseName : "\(imageBaseName)_disabled"
    }
    
    private var displayTextColor: Color {
        guard isEnabled else { return Color.primaryGray300 }
        return title == "휴지통" ? Color.supportingRed500 : Color.primaryGray700
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 1) {
                Image(displayIconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(title)
                    .textStyle(.headingMdSemiBold)
                    .foregroundColor(displayTextColor)
            }
        }
    }
}
