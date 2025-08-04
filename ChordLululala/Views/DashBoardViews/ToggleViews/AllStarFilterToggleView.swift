//
//  FileFolderFilterToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct AllStarFilterToggleView: View {
    @Binding var selectedFilter: ToggleFilter
    
    private let tabHeight: CGFloat = 23
//    private let buttonSpacing: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(ToggleFilter.allCases.enumerated()), id: \.element.id) { index, filter in
                let isSelected = (filter == selectedFilter)
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .textStyle(.bodyTextXLMedium)
                        .foregroundColor(isSelected ? Color.primaryBlue600 :Color.primaryBaseBlack)
                        .frame(maxWidth: .infinity, minHeight: tabHeight)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.primaryBaseWhite : Color.clear)
                        .cornerRadius(5)
//                        .overlay(overlayView(isSelected: isSelected))
                        .shadow(color: isSelected ? Color.black.opacity(10/255.0) : Color.clear, radius: 1, x: 0, y: 3)
                        .shadow(color: isSelected ? Color.black.opacity(31/255.0) : Color.clear, radius: 8, x: 0, y: 3)
                }
                // 버튼 사이
//                if index < ToggleFilter.allCases.count - 1 {
//                    Capsule()
//                        .fill(Color.primaryGray400)
//                        .frame(width: 1, height: 12)
//                        .padding(.horizontal, buttonSpacing)
//                }
            }
        }
        .padding(4)
        .frame(width: 139)
        .background(Color.primaryGray200)
        .cornerRadius(6)
    }
    
//    @ViewBuilder
//    private func overlayView(isSelected: Bool) -> some View {
//        if isSelected {
//            RoundedRectangle(cornerRadius: 7)
//                .stroke(Color.primaryGray100, lineWidth: 0.5)
//        } else {
//            EmptyView()
//        }
//    }
}
