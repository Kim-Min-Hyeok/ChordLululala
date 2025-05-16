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
        return title == "휴지통" ? Color.supportingRed500 : Color.primaryGray900
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(displayIconName)
                    .resizable()
                    .frame(width: 39, height: 39)
                Text(title)
                    .textStyle(.headingSmMedium)
                    .foregroundColor(displayTextColor)
            }
        }
    }
}
