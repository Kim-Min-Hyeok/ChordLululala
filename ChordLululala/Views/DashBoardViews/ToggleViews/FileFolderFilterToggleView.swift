//
//  FileFolderFilterToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileFolderFilterToggleView: View {
    @Binding var selectedFilter: ToggleFilter
    
    private let tabHeight: CGFloat = 28
    private let buttonSpacing: CGFloat = 1.33
    private let separatorSpacing: CGFloat = 2.33
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(ToggleFilter.allCases.enumerated()), id: \.element.id) { index, filter in
                let isSelected = (filter == selectedFilter)
                
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: tabHeight)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white : Color.clear)
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                if index < ToggleFilter.allCases.count - 1 {
                    Spacer()
                        .frame(width: buttonSpacing)
                }
            }
            
            Spacer()
                .frame(width: separatorSpacing)
                
            Capsule()
                .fill(Color.gray)
                .frame(width: 1, height: 12)
        }
        .padding(2)
        .background(Color(UIColor.lightGray))
        .cornerRadius(9)
    }
}
