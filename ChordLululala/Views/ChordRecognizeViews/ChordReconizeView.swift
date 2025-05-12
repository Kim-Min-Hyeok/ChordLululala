//
//  ChordReconizeView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/10/25.
//

import SwiftUI

struct ChordReconizeView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var vm = ChordRecognizeViewModel()
    let file: ContentModel

    @State private var showResult = false

    var body: some View {
        ZStack {
            Color.primaryGray50.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { router.back() } label: {
                        Text("끝내기")
                            .textStyle(.headingLgSemiBold)
                            .foregroundColor(.supportingRed600)
                    }
                    Spacer()
                    HStack(spacing: 7) {
                        if !showResult {
                            Image("scoreheader_loading")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                        }
                        Text(showResult ? "인식 완료" : "인식중")
                            .textStyle(.headingLgSemiBold)
                    }
                    .foregroundColor(.primaryBlue600)
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .frame(height: 83)
                .background(Color.primaryBaseWhite)

                // Body: loading or result
                if !showResult {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear { vm.startRecognition(for: file) }
                        .onReceive(vm.$doneCount) { done in
                            if vm.totalCount > 0 && done >= vm.totalCount {
                                showResult = true
                            }
                        }
                } else {
                    ChordRecognizeResultView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
