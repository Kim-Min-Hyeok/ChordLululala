//
//  ChordConfirmView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

struct ChordConfirmView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var vm = ChordConfirmViewModel()
    
    let file: Content

    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()

            Text("코드 변환 완료")
                .textStyle(.displayXLSemiBold)
                .foregroundColor(.primaryGray900)

            HStack(spacing: 16.64) {
                let previewCount = min(3, vm.pagesImages.count, vm.chordLists.count)
                
                ForEach(0..<previewCount, id: \.self) { idx in
                    ChordPagePreviewView(
                        image: vm.pagesImages[idx],
                        chords: vm.chordLists[idx],
                        transposed: vm.transposedChord(for:)
                    )
                }
            }
            .padding(.top, 62.33)

            Spacer()

            Button(action: {
                NotificationCenter.default.post(name: .didTransposeChord, object: file)
                router.back()
            }) {
                Text("해당 악보 바로 시작하기")
                    .textStyle(.headingMdSemiBold)
                    .padding(.vertical, 14.5)
                    .frame(maxWidth: 310)
                    .background(Color.primaryBlue600)
                    .foregroundColor(Color.primaryBaseWhite)
                    .cornerRadius(10)
            }
            .padding(.bottom, 107)
        }
        .padding(.horizontal, 44)
        .onAppear {
            vm.load(from: file)
            print("원래 키:", vm.key, "변환될 키:", vm.t_key, "isSharp:", vm.isSharp)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("변환 결과 예시:", vm.transposedChord(for: "D"))
            }
        }
    }
}
