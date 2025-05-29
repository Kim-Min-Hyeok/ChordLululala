//
//  KeyTranspositionModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/29/25.
//

import SwiftUI

struct KeyTranspositionModalView: View {
    let currentKey: String
    var onConfirm: (_ newKey: String) -> Void
    var onCancel: () -> Void
    
    @State private var targetKey: String
    
    init(
        currentKey: String,
        onConfirm: @escaping (_ newKey: String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.currentKey = currentKey
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _targetKey = State(initialValue: currentKey)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image("cancel_fixing_key")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            
            Text("변환할 조(key)")
                .textStyle(.headingMdSemiBold)
                .foregroundColor(.primaryGray900)
                .padding(.top, 30)
            
            Text("해당 악보를 어떤 조(key)로 변경하시겠습니까?")
                .textStyle(.bodyTextLgRegular)
                .foregroundColor(.primaryGray500)
                .padding(.top, 9)
            
            VStack(spacing: 11) {
                HStack {
                    Text("현재 조")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGray600)
                    Spacer()
                    Text(currentKey)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryGray600)
                        .frame(width: 176, height: 46)
                        .background(Color.primaryGray50)
                        .cornerRadius(5)
                }
                
                HStack {
                    Text("변환할 조")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGray600)
                    Spacer()
                    TextField("조 입력", text: $targetKey)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .frame(width: 176, height: 46)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.primaryGray100)
                        )
                }
            }
            .padding(.horizontal, 41)
            .padding(.top, 28)
            
            Divider()
                .background(Color.primaryGray300)
                .padding(.top, 24)
            
            Button(action: {
                onConfirm(targetKey)
            }) {
                Text("변환 진행")
                    .textStyle(.headingLgSemiBold)
                    .foregroundColor(.primaryBlue600)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .frame(width: 321)
        .background(Color.primaryBaseWhite)
        .cornerRadius(10)
        .shadow(radius: 30)
    }
}
