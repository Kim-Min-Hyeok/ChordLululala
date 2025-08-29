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
    @StateObject private var presetVM = ChordPresetViewModel()
    let file: Content
    
    @State private var showAddingModal = false
    @State private var showFixingKeyModal = false
    @State private var showKeyFixingAndTransposeModal = false
    
    var body: some View {
        ZStack {
            Color.primaryGray50.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                ChordRecognizeHeaderView(
                    state: vm.state,
                    onBack: { router.back() },
                    onFixingKey: {
                        // MARK: Plan B Start
                        if vm.state == .keyFixing {
                            showFixingKeyModal = true
                        }
                        // MARK: Plan B End
                        // MARK: Plan A Start
//                        if vm.state == .keyFixingAndTransposition {
//                            showKeyFixingAndTransposeModal = true
//                        }
                        // MARK: Plan A End
                    },
                    // onCreateBox: {
                    //     vm.editingChord = nil
                    //     showAddingModal = true
                    // },
                    onFinalize: {
                        vm.state = .keyTranspostion
                        vm.showKeyTranspositionModal = true
                    }
                )
                
                // Body: loading or result
                switch vm.state {
                case .recognition:
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear { vm.startRecognition(for: file) }
                        .onReceive(vm.$doneCount) { done in
                            if vm.state == .recognition,
                               vm.totalCount > 0, done >= vm.totalCount {
                                // MARK: Plan B Start
                                vm.state = .keyFixing
                                // MARK: Plan B End
                                // MARK: Plan A Start
//                                vm.state = .keyFixingAndTransposition
                                // MARK: Plan A Start
                                vm.findKey()
                                showFixingKeyModal = true
                            }
                        }
                case .keyFixing, .chordFixing, .keyTranspostion: /*.keyFixingAndTransposition:*/
                    ZStack {
                        ChordRecognizeResultView(
                            onBackgroundTap: {
                                if vm.state == .chordFixing {
                                    presetVM.isVisible.toggle()
                                }
                            }
                        )
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        if vm.state == .chordFixing && presetVM.isVisible {
                            VStack {
                                Spacer()
                                ChordPresetView(
                                    chords: presetVM.recentChords,
                                    onPlus: {
                                        vm.editingChord = nil
                                        showAddingModal = true
                                    },
                                    onSelect: { chord in
                                        vm.addNewChordAtCenter(text: chord, to: vm.selectedPage)
                                        presetVM.push(chord)
                                    }
                                )
                                .frame(maxWidth: 391)
                                .padding(.horizontal, 220)
                                .padding(.bottom, 17)
                            }
                        }
                    }
                }
            }
            
            if vm.state == .keyFixing && showFixingKeyModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showFixingKeyModal = false
                            // 프리셋 초기화 및 자동 표시
                            presetVM.initializeWithFrequencies(from: vm.scoreChords, transposer: { vm.transposedChord(for: $0) })
                            presetVM.isVisible = true
                        }
                    
                    FixingKeyModalView(
                        onConfirm: { keyText, transposeAmount in
                            vm.key = keyText
                            vm.t_key = keyText
                            vm.transposeAmount = transposeAmount
                            vm.fixingKey(for: file)
                            showFixingKeyModal = false
                            vm.state = .chordFixing
                            // 프리셋 초기화 및 자동 표시
                            presetVM.initializeWithFrequencies(from: vm.scoreChords, transposer: { vm.transposedChord(for: $0) })
                            presetVM.isVisible = true
                        },
                        onCancel: {
                            withAnimation {
                                showFixingKeyModal = false
                            }
                        },
                        title: "악보 인식 결과",
                        description: "조성이 올바르다면 다음을 눌러주세요",
                        subtitle: "",
                        initialKey: vm.key,
                        initialIsSharp: vm.isSharp,
                        initialTransposeAmount: vm.transposeAmount
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
                .zIndex(2)
            }
            
            if vm.state == .chordFixing && (showAddingModal || vm.editingChord != nil) {
                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showAddingModal = false
                                vm.editingChord = nil
                            }
                        }
                    
                    // 모달 뷰 자체
                    ChordAddingModalView(
                        editingChord: vm.editingChord,
                        onCancel: {
                            withAnimation {
                                showAddingModal = false
                                vm.editingChord = nil
                            }
                        },
                        onConfirm: { text in
                            if text.isEmpty { return }
                            
                            if let editing = vm.editingChord {
                                    vm.updateChord(editing: editing, newText: text)
                                } else {
                                    vm.addNewChordAtCenter(text: text, to: vm.selectedPage)
                                }
                            
                            // 프리셋 업데이트 및 표시 유지
                            presetVM.push(text)
                            
                            withAnimation {
                                showAddingModal = false
                                vm.editingChord = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
                .zIndex(1)
            }
            if vm.state == .keyTranspostion && vm.showKeyTranspositionModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            vm.showKeyTranspositionModal = false
                            vm.state = .chordFixing
                            presetVM.isVisible = true
                        }
                    
                    FixingKeyModalView(
                        onConfirm: { keyText, transposeAmount in
                            vm.t_key = keyText
                            vm.transposeAmount = transposeAmount
                            vm.applyTransposedKey(for: file)
                            vm.showKeyTranspositionModal = false
                            vm.finalizeChordRecognition {
                                router.offNamed("/chordConfirm", arguments: [file])
                            }
                        },
                        onCancel: {
                            vm.showKeyTranspositionModal = false
                            vm.state = .chordFixing
                            presetVM.isVisible = true
                        },
                        title: "변환할 조 선택",
                        description: "어떤 조(key)로 변경하시겠습니까?",
                        subtitle: "기존 조: \(vm.key), 현재 조: \(vm.t_key)",
                        initialKey: vm.t_key,
                        initialIsSharp: vm.isSharp,
                        initialTransposeAmount: vm.transposeAmount
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
    }
}

