//
//  SetlistCandidateView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI

struct SetlistCandidateView: View {
    @EnvironmentObject var dashBoardViewModel: DashBoardViewModel
    @EnvironmentObject var viewModel: CreateSetlistViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.filteredScores, id: \.objectID) { content in
                        CandidateCellView(file: content)
                    }
                }
            }
            .padding(.top, dashBoardViewModel.isLandscape ? 40 : 30)
            .padding(.horizontal,  30)
        }
        .background(Color.primaryBaseWhite)
        .cornerRadius(14)
    }
}
