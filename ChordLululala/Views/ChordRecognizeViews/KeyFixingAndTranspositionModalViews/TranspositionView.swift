//
//  TranspositionView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/29/25.
//

import SwiftUI

struct TranspositionView: View {
    let currentKey: String
    var onConfirm: (_ newKey: String) -> Void
    var onCancel: () -> Void
    
    @State private var transposeKey: String
    
    init(
        currentKey: String,
        onConfirm: @escaping (_ newKey: String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.currentKey = currentKey
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _transposeKey = State(initialValue: currentKey)
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
            
            HStack(spacing: 8.52) {
                Image("check_true")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 29.81, height: 29.81)
                    .shadow(color: Color(hex:"2563EB").opacity(0.24), radius: 8.2, x: 0, y: 4.26)
                
                HStack(spacing: 3.9) {
                    Circle().fill(Color.primaryBlue600).frame(width: 3.61, height: 3.61)
                    Circle().fill(Color.primaryBlue600).frame(width: 3.61, height: 3.61)
                    Circle().fill(Color.primaryBlue600).frame(width: 3.61, height: 3.61)
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.primaryGray300, lineWidth: 1.06)
                        .frame(width: 29.81, height: 29.81)
                        .shadow(color: Color(hex:"2563EB").opacity(0.24), radius: 8.2, x: 0, y: 4.26)
                    Text("2")
                        .textStyle(.headingLgMedium)
                        .foregroundColor(Color.primaryGray300)
                }
            }
            .padding(.top, 3.56)
            
            HStack(spacing: 4) {
                Text("변환할 조")
                    .textStyle(.headingXLBold)
                    .foregroundColor(Color.primaryGray900)
                Text("선택")
                    .textStyle(.headingXLMedium)
                    .foregroundColor(Color.primaryGray900)
            }
            .padding(.top, 21.63)
            
            Text("어떤 조(key)로 변경하시겠습니까?")
                .textStyle(.bodyTextLgRegular)
                .foregroundColor(.primaryGray500)
                .padding(.top, 5)
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Text(currentKey)
                        .textStyle(.displayXLMedium)
                        .foregroundColor(.primaryGray900)
                        .frame(width: 115.94, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.primaryGray50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.primaryGray100, lineWidth: 1)
                                )
                        )
                        .cornerRadius(3)
                    Spacer()
                    Image("arrow_forward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Spacer()
                    TextField("조 입력", text: $transposeKey)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .frame(width: 115.94, height: 56)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.primaryGray100)
                        )
                }
                .padding(.horizontal, 19)
                
                HStack(alignment: .center, spacing: 10) {
                    Image("warning_code")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                    
                    HStack(spacing: 3) {
                        Text("모든 코드가 ")
                            .textStyle(.bodyTextLgMedium)
                            .foregroundStyle(Color.primaryGray900)
                        Text("2프렛 또는 2반음")
                            .textStyle(.bodyTextLgBold)
                            .foregroundStyle(Color.primaryGray900)
                        Text("으로 변환됩니다.")
                            .textStyle(.bodyTextLgMedium)
                            .foregroundStyle(Color.primaryGray900)
                    }
                }
                .cornerRadius(200)
                .frame(width: 282, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 200)
                        .fill(Color.primaryGray50)
                )
            }
            
            Spacer()
            
            Divider()
                .background(Color.primaryGray300)
                .padding(.top, 24)
            
            Button(action: {
                onConfirm(transposeKey)
            }) {
                Text("변환 진행")
                    .textStyle(.headingLgSemiBold)
                    .foregroundColor(.primaryBlue600)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
