//
//  SortToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SortToggleView: View {
    @Binding var selectedSort: SortOption
    private let spacing: CGFloat = 11
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(SortOption.allCases) { option in
                Button(action: {
                    selectedSort = option
                }) {
                    Text(option.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(option == selectedSort ? .black : .gray)
                }
            }
        }
    }
}
