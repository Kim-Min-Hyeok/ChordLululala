//
//  ChordAddingFieldView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordAddingFieldView: View {
    @EnvironmentObject var viewModel: ChordAddingModalViewModel
    
    var body: some View {
        VStack(spacing: 5.5) {
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.undo()
                }) {
                    Image("undo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 41)
                }
                HStack {
                    Spacer()
                    Text(viewModel.chord)
                        .textStyle(.headingSmSemiBold)
                        .foregroundStyle(Color.primaryGray800)
                    Spacer()
                }
                .frame(width: 262, height: 45)
                .background(Color.primaryBaseWhite)
                .cornerRadius(4)
                .shadow(color: Color.primaryBaseBlack.opacity(0.15), radius: 4, x: 0, y: 2)
                Button(action: {
                    viewModel.redo()
                }) {
                    Image("redo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 41)
                }
            }
            
            Text("유효하지 않은 코드입니다. 올바른 조합인지 확인해주세요.")
                .textStyle(.bodyTextLgMedium)
                .foregroundStyle(viewModel.isValidChord(viewModel.chord) ? Color.clear : Color.supportingRed600)
        }
        .padding(.top, 20.5)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "E2E4E7").opacity(0.25))
    }
}
