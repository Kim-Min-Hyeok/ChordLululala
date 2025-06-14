//
//  ChordAddingKeyboardView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordAddingKeyboardView: View {
    @EnvironmentObject var viewModel: ChordAddingModalViewModel
    
    let baseNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let symbols = ["♭", "#", "/"]
    let chordTypes = ["M", "m", "sus2", "5", "sus4", "Aug", "Dim"]
    let tensions = ["9", "b9", "#9", "11", "#11", "13", "b13", "6", "7", "maj7", "add9", "add2", "b5"]

    var body: some View {
        HStack(alignment: .top, spacing: 28.42) {
            VStack(alignment: .leading, spacing: 24.36) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("기본음 (base note)")
                        .textStyle(.headingSmSemiBold)
                        .foregroundColor(Color.primaryGray800)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<4) { i in
                            HStack(spacing: 9) {
                                if i * 2 < baseNotes.count {
                                    Button(action: {
                                        
                                    }) {
                                        baseNoteButton(title: baseNotes[i * 2])
                                    }
                                }
                                if i * 2 + 1 < baseNotes.count {
                                    Button(action: {
                                        
                                    }) {
                                        baseNoteButton(title: baseNotes[i * 2 + 1])
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(symbols.indices, id: \.self) { idx in
                        Button(action: {
                            viewModel.append(symbols[idx])
                        }) {
                            Text(symbols[idx])
                                .textStyle(.headingSmMedium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .foregroundColor(Color.primaryGray400)
                                .background(Color.primaryGray100)
                        }
                        .shadow(color: Color(hex: "111827").opacity(0.15), radius: 2, x: -1, y: 1)
                    }
                }
                .frame(width: 233, height: 31)
                .cornerRadius(12)
                .shadow(color: Color(hex: "111827").opacity(0.15), radius: 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity) // 왼쪽 column

            // ─ 오른쪽: 코드타입 + 텐션 ─
            VStack(alignment: .leading, spacing: 19) {
                
                // 코드타입
                VStack(alignment: .leading, spacing: 6) {
                    Text("코드타입")
                        .textStyle(.bodyTextLgMedium)
                        .foregroundColor(Color.primaryGray800)

                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(0..<2) { row in
                            HStack(spacing: 4) {
                                ForEach(0..<4) { col in
                                    let index = row * 4 + col
                                    if index < chordTypes.count {
                                        codeTypeButton(title: chordTypes[index])
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 텐션
                VStack(alignment: .leading, spacing: 6) {
                    Text("텐션")
                        .textStyle(.bodyTextLgMedium)
                        .foregroundColor(Color.primaryGray800)

                    VStack(alignment: .leading, spacing: 4.4) {
                        ForEach(0..<5) { row in
                            HStack(spacing: 4.55) {
                                ForEach(0..<3) { col in
                                    let index = row * 3 + col
                                    if index < tensions.count {
                                        tensionButton(title: tensions[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity) // 오른쪽 column
        }
        .padding(.horizontal, 25)
        .padding(.top, 11)
        .padding(.bottom, 22.53)
    }

    @ViewBuilder
    private func baseNoteButton(title: String) -> some View {
        Button(action: {
            viewModel.append(title)
        }) {
            Text(title)
                .textStyle(.headingSmMedium)
                .frame(width: 111.79, height: 48.41)
                .background(Color.primaryGray100)
                .foregroundColor(Color.primaryGray400)
                .cornerRadius(8)
                .shadow(color: Color(hex: "1F2937").opacity(0.15), radius: 2, x: 0, y: 0)
        }
    }
    
    @ViewBuilder
    private func codeTypeButton(title: String) -> some View {
        Button(action: {
            viewModel.append(title)
        }) {
            Text(title)
                .textStyle(.headingSmMedium)
                .frame(width: 54.7, height: 44.47)
                .background(Color.primaryGray100)
                .foregroundColor(Color.primaryGray400)
                .cornerRadius(3)
                .shadow(color: Color(hex: "1F2937").opacity(0.15), radius: 2, x: 0, y: 1)
        }
    }
    
    @ViewBuilder
    private func tensionButton(title: String) -> some View {
        Button(action: {
            viewModel.append(title)
        }) {
            Text(title)
                .textStyle(.headingSmMedium)
                .frame(width: 74, height: 30.31)
                .background(Color.primaryGray100)
                .foregroundColor(Color.primaryGray400)
                .cornerRadius(8)
                .shadow(color: Color(hex: "1F2937").opacity(0.15), radius: 2, x: 0, y: 1)
        }
    }
}
