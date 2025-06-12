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
                    onCreateBox: {
                        vm.editingChord = nil
                        showAddingModal = true
                    },
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
                    ChordRecognizeResultView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            if vm.state == .keyFixing && showFixingKeyModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showFixingKeyModal = false
                            }
                        }
                    
                    FixingKeyModalView(
                        onConfirm: { keyText, transposeAmount in
                            // 여기에서 ViewModel 업데이트 등 처리
                            vm.key = keyText
                            vm.t_key = keyText
                            vm.transposeAmount = transposeAmount
                            vm.fixingKey(for: file)
                            withAnimation {
                                showFixingKeyModal = false
                                vm.state = .chordFixing
                            }
                        },
                        onCancel: {
                            withAnimation {
                                showFixingKeyModal = false
                            }
                        },
                        title: "조(key) 인식 결과",
                        description: "인식 결과 확인후, 수정해주세요.\n수정할 사항이 없다면 설정 완료를 눌러주세요.",
                        subtitle: "인식 결과",
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
                                    vm.addNewChord(text: text, to: vm.selectedPage, position: CGPoint(x: 100, y:100))
                                }
                            
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
                            withAnimation {
                                vm.showKeyTranspositionModal = false
                            }
                        }
                    
//                    KeyTranspositionModalView(
//                        currentKey: vm.t_key,
//                        onConfirm: { newKey in
//                            vm.applyTransposedKey(newKey, for: file)
//                            withAnimation {
//                                showKeyTranspositionModal = false
//                                vm.finalizeChordRecognition {
//                                    router.offNamed("/chordConfirm", arguments: [file])
//                                }
//                            }
//                        },
//                        onCancel: {
//                            withAnimation {
//                                showKeyTranspositionModal = false
//                                vm.state = .chordFixing
//                            }
//                        }
//                    )
                    FixingKeyModalView(
                        onConfirm: { keyText, transposeAmount in
                            // 여기에서 ViewModel 업데이트 등 처리
                            vm.t_key = keyText
                            vm.transposeAmount = transposeAmount
                            vm.applyTransposedKey(for: file)
                            withAnimation {
                                vm.showKeyTranspositionModal = false
                                vm.finalizeChordRecognition {
                                    router.offNamed("/chordConfirm", arguments: [file])
                                }
                            }
                        },
                        onCancel: {
                            withAnimation {
                                vm.showKeyTranspositionModal = false
                                vm.state = .chordFixing
                            }
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
//            if vm.state == .keyFixingAndTransposition && showKeyFixingAndTransposeModal {
//                ZStack {
//                    Color.black.opacity(0.001)
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation {
//                                showKeyFixingAndTransposeModal = false
//                            }
//                        }
//                    
//                    // 모달 뷰 자체
//                    KeyFixingAndTranspositionModalView(
//                        onConfirm: { originalKey, transposeKey in
//                            vm.key = originalKey
//                            vm.t_key = transposeKey
//                            vm.fixingKey(for: file)
//                            withAnimation {
//                                vm.state = .chordFixing
//                                showKeyTranspositionModal = false
//                                
//                            }
//                        },
//                        onCancel: {
//                            withAnimation {
//                                showKeyFixingAndTransposeModal = false
//                            }
//                        },
//                        initialKey: vm.key,
//                        initialIsSharp: vm.isSharp,
//                        initialTransposeAmount: vm.transposeAmount
//                        
//                    )
//                    .transition(.move(edge: .bottom))
//                    .zIndex(2)
//                }
//                .zIndex(2)
//            }
        }
        .onAppear() {
            print("원래 키:", vm.key, "변환될 키:", vm.t_key, "isSharp:", vm.isSharp)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("변환 결과 예시:", vm.transposedChord(for: "D"))
            }
        }
        .navigationBarHidden(true)
    }
}

