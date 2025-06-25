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
    
    @State private var isAddingScore: Bool = false
    
    @Binding var scores: [Content]
    let moveScore: (IndexSet, Int) -> Void
    let deleteScore: (Content) -> Void
    let addScores: ([Content]) -> Void
    
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                Text("셋리스트 목록")
                    .textStyle(.headingSmSemiBold)
                    .foregroundStyle(Color.primaryGray800)
                HStack {
                    Spacer()
                    if !isAddingScore {
                        Button(action: { isAddingScore = true }) {
                            Text("악보 추가")
                                .textStyle(.bodyTextLgSemiBold)
                                .foregroundStyle(Color.primaryBlue600)
                        }
                    } else {
                        Button(action: {
                            addScores(viewModel.selectedContents)
                            isAddingScore = false
                        }) {
                            Text("완료")
                                .textStyle(.bodyTextLgSemiBold)
                                .foregroundStyle(Color.primaryBlue600)
                        }
                    }
                }
                .padding(.trailing, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(Color.primaryGray50)
            
            if !isAddingScore {
                List {
                    ForEach(scores, id: \.objectID) { score in
                        ScoreInSelistCellView(
                            score: score,
                            keyTransformation: {
                                router.toNamed("/chordreconize", arguments: [ score ])
                            },
                            deleteScore: {
                                withAnimation {
                                    deleteScore(score)
                                }
                            },
                            gotoScoreDetail: {
                                router.toNamed("/score", arguments: [ score ])
                            }
                        )
                        .frame(height: 74)
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.primaryGray200)
                        .listRowBackground(
                            VStack(spacing: 0) {
                                if score == scores.last {
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
                    .onMove(perform: moveScore)
                }
                .listRowSpacing(0)
                .listStyle(PlainListStyle())
                .environment(\.editMode, .constant(.active))
                .padding(.top, 28)
                .padding(.horizontal, 24)

            }
            else {
                ScoreForSetlistSearchView(viewModel: viewModel)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.filteredScores, id: \.objectID) { content in
                            ScoreForSetlistCellView(viewModel: viewModel, file: content)
                                .frame(height: 74)
                                .background(
                                    VStack(spacing: 0) {
                                        if content == viewModel.filteredScores.last {
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
                        }
                    }
                }
                .padding(.top, 18)
                .padding(.horizontal, 24)
            }
        }
        .frame(width: 478, height: 620)
        .background(Color.primaryBaseWhite)
        .cornerRadius(18)
        .shadow(color: Color.primaryBaseBlack.opacity(25) , radius: 30)
    }
}
