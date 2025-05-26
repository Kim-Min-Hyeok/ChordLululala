//
//  SetContentNameModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI

struct SetContentNameModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @FocusState private var isFocused: Bool
    @State private var name: String = ""
    
    let titleText: String
    let bodyText: String
    let originalName: String
    let onComplete: (String) -> Void
    let onCancel: () -> Void
    
    init(
        _ titleText: String,
        _ bodyText: String,
        _ originalName: String,
        onComplete: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    )  {
        self.titleText = titleText
        self.bodyText = bodyText
        self.originalName = originalName
        self.onComplete = onComplete
        self.onCancel = onCancel
        self._name = State(initialValue: originalName)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(titleText)
                .textStyle(.headingMdSemiBold)
                .foregroundColor(.primaryGray900)
                .padding(.top, 18)
            
            Text(bodyText)
                .textStyle(.bodyTextLgRegular)
                .foregroundColor(.primaryGray500)
                .padding(.top, 8)
            
            ZStack(alignment: .trailing) {
                TextField("무제", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                
                if !name.isEmpty {
                    Button(action: {
                        name = ""
                    }) {
                        Image("cancel")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 31, height: 31)
                }
            }
            .padding(.horizontal, 27)
            .padding(.top, 18)
            
            Divider()
                .foregroundStyle(Color.primaryGray300)
                .padding(.top, 18)
            HStack {
                Button("취소") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .foregroundStyle(Color.primaryGray300)
                
                Button("확인") {
                    if name != originalName {
                        onComplete(name)
                    } else {
                        onCancel()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 51)
        }
        .frame(width: 309)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primaryBaseWhite.opacity(0.9))
                .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}
