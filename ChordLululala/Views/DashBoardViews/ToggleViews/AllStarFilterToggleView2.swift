//
//  FileFolderFilterToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct AllStarFilterToggleView2: View {
    @Binding var selectedFilter: ToggleFilter
    
    private let tabHeight: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(ToggleFilter.allCases.enumerated()), id: \.element.id) { index, filter in
                let isSelected = (filter == selectedFilter)
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .textStyle(.bodyTextXLMedium)
                        .foregroundColor(Color.primaryBaseBlack)
                        .frame(maxWidth: .infinity, minHeight: tabHeight)
                        .background(isSelected ? Color.primaryBaseWhite : Color.clear)
                        .cornerRadius(7)
                        .overlay(overlayView(isSelected: isSelected))
                        .shadow(color: isSelected ? Color.black.opacity(10/255.0) : Color.clear, radius: 1, x: 0, y: 3)
                        .shadow(color: isSelected ? Color.black.opacity(31/255.0) : Color.clear, radius: 8, x: 0, y: 3)
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 5.5)
        .background(Color.primaryGray200)
        .cornerRadius(9)
    }
    
    @ViewBuilder
    private func overlayView(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.primaryGray100, lineWidth: 0.5)
        } else {
            EmptyView()
        }
    }
}
