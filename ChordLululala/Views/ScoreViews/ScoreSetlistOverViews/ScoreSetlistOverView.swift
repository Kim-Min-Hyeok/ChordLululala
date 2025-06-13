//
//  ScoreSetlistOverView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/13/25.
//

import SwiftUI

struct ScoreSetlistOverView: View {
    @EnvironmentObject var router : NavigationRouter
    @ObservedObject var viewModel: ScoreSetlistOverViewModel
    
    var body: some View {
        VStack(spacing: 0){
            VStack(alignment: .center) {
                Text("셋리스트 목록")
                    .textStyle(.headingSmSemiBold)
                    .foregroundStyle(Color.primaryGray800)
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(Color.primaryGray50)
            
            List {
                ForEach(viewModel.scores, id: \.objectID) { score in
                    ScoreCellView(
                        score: score,
                        keyTransformation: {
                            router.toNamed("/chordreconize", arguments: [ score ])
                        },
                        deleteScore: {
                            withAnimation {
                                viewModel.deleteScore(score)
                            }
                        }
                    )
                    .frame(height: 74)
                    .listRowSeparator(.hidden)
                    .listRowSeparatorTint(Color.primaryGray200)
                    .listRowBackground(
                        VStack(spacing: 0) {
                            if score == viewModel.scores.last {
                                Color.primaryBaseWhite
                                    .frame(height: 74)
                            } else {
                                Color.primaryBaseWhite
                                    .frame(height: 73)
                                Rectangle()
                                    .fill(Color.primaryGray200)
                                    .frame(height: 1)
                            }
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .onMove(perform: viewModel.moveScore)
            }
            .listRowSpacing(0)
            .listStyle(PlainListStyle())
            .environment(\.editMode, .constant(.active))
            .padding(.top, 28)
            .padding(.horizontal, 24)
        }
        .frame(width: 478, height: 620)
        .background(Color.primaryBaseWhite)
        .cornerRadius(18)
        .shadow(color: Color.primaryBaseBlack.opacity(25) , radius: 30)
    }
}
