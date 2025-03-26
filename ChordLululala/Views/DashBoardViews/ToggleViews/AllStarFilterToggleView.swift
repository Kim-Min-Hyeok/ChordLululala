//
//  FileFolderFilterToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct AllStarFilterToggleView: View {
    @Binding var selectedFilter: ToggleFilter
    
    private let tabHeight: CGFloat = 28
    private let buttonSpacing: CGFloat = 1.33
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(ToggleFilter.allCases.enumerated()), id: \.element.id) { index, filter in
                let isSelected = (filter == selectedFilter)
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: tabHeight)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white : Color.clear)
                        .cornerRadius(7)
                        .overlay(overlayView(isSelected: isSelected))
                }
                // 버튼 사이에만 캡슐 구분선 삽입
                if index < ToggleFilter.allCases.count - 1 {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 1, height: 12)
                        .padding(.horizontal, buttonSpacing)
                }
            }
        }
        .padding(2)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(9)
    }
    
    @ViewBuilder
    private func overlayView(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.gray, lineWidth: 0.5)
        } else {
            EmptyView()
        }
    }
}
