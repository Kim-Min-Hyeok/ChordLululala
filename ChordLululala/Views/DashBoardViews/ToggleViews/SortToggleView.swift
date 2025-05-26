//
//  SortToggleView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SortToggleView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    private let spacing: CGFloat = 15
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(SortOption.allCases) { option in
                Button(action: {
                    viewModel.toggleSortOption(option)
                }) {
                    HStack(spacing: 3) {
                        Text(option.rawValue)
                            .textStyle(.headingMdSemiBold)
                            .foregroundColor(option == viewModel.selectedSort ? Color.primaryGray900 : Color.primaryGray400)

                        
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12))
                                .foregroundColor(viewModel.selectedSort == option ? Color.primaryGray900 : Color.primaryGray400)
                        
                    }
                }
            }
        }
    }
}
