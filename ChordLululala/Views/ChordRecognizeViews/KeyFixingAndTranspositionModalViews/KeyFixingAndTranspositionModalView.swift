//
//  KeyFixingAndTranspositionModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/29/25.
//

import SwiftUI

enum Step {
    case fixing
    case transposition
}

struct KeyFixingAndTranspositionModalView: View {
    let onConfirm: (_ originalKey: String, _ transposeKey: String) -> Void
    let onCancel: () -> Void
    
    let initialKey: String
    let initialIsSharp: Bool
    let initialTransposeAmount: Int
    
    @State private var step: Step = .fixing
    @State private var originalKey: String = "C"
    @State private var transposeKey: String = "C"
    @State private var transposeAmount: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            switch step {
            case .fixing:
                FixingView(
                    onConfirm: { keyText, transposeAmount in
                        self.originalKey = keyText
                        self.transposeKey = keyText
                        self.transposeAmount = transposeAmount
                        self.step = .transposition
                    },
                    onCancel: {
                        onCancel()
                    },
                    initialKey: initialKey,
                    initialIsSharp: initialIsSharp,
                    initialTransposeAmount: initialTransposeAmount
                )
            case .transposition:
                TranspositionView(
                    currentKey: transposeKey,
                    onConfirm: { newKey in
                        transposeKey = newKey
                        onConfirm(originalKey, transposeKey)
                    },
                    onCancel: {
                        onCancel()
                    }
                )
            }
        }
        .frame(maxWidth: 321, maxHeight: 501)
        .background(Color.primaryBaseWhite)
        .cornerRadius(10)
        .shadow(radius: 30)
    }
}
