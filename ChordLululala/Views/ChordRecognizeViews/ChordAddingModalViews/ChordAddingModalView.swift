//
//  ChordAddingModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordAddingModalView: View {
    @StateObject private var vm = ChordAddingModalViewModel()
    
    let editingChord: ScoreChord?
    let onCancel: () -> Void
    let onConfirm: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("코드 박스 생성")
                .textStyle(.headingMdSemiBold)
                .foregroundStyle(Color.primaryGray900)
                .padding(.top, 18)
            Text("원하는 코드를 선택한 후, 생성 버튼을 눌러주세요")
                .textStyle(.bodyTextLgRegular)
                .foregroundStyle(Color.primaryGray500)
                .padding(.top, 8)
            
            ChordAddingFieldView()
                .padding(.top, 18)
            
            ChordAddingKeyboardView()
            
            Divider()
                .foregroundStyle(Color.primaryGray300)
            HStack(spacing: 0) {
                Button(action: {
                    onCancel()
                }) {
                    Text("취소")
                        .textStyle(.headingLgMedium)
                        .foregroundStyle(Color.primaryBlue600)
                        .frame(height: 51)
                        .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(width: 1, height: 51)
                    .foregroundStyle(Color.primaryGray300)
                Button(action: {
                    onConfirm(vm.chord)
                }) {
                    Text(editingChord == nil ? "생성" : "수정")
                        .textStyle(.headingLgSemiBold)
                        .foregroundStyle(vm.isValidChord(vm.chord) ? Color.primaryBlue600: Color.primaryGray300)
                        .frame(height: 51)
                        .frame(maxWidth: .infinity)
                }
                .disabled(vm.isValidChord(vm.chord) == false)
            }
        }
        .onAppear {
            if let chord = editingChord {
                vm.setInitialChord(chord.chord ?? "C")
            } else {
                vm.setInitialChord("")
            }
        }
        .frame(maxWidth: 535)
        .background(Color.primaryBaseWhite)
        .cornerRadius(10)
        .shadow(color: Color.primaryBaseBlack.opacity(0.1), radius: 20, x: 0, y: 0)
        .environmentObject(vm)
    }
}
