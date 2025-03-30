//
//  SortToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SortToggleView: View {
    @Binding var selectedSort: SortOption
    private let spacing: CGFloat = 15
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(SortOption.allCases) { option in
                Button(action: {
                    selectedSort = option
                }) {
                    Text(option.rawValue)
                        .textStyle(.headingMdSemiBold)
                        .foregroundColor(option == selectedSort ? Color.primaryGray900 : Color.primaryGray400)
                }
            }
        }
    }
}
