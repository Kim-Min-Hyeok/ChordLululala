//
//  FixingView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/29/25.
//

import SwiftUI

struct FixingView: View {
    let onConfirm: (_ keyText: String, _ transposeAmount: Int) -> Void
    let onCancel: () -> Void
    let initialKey: String
    let initialIsSharp: Bool
    let initialTransposeAmount: Int
    
    @State private var keyText: String = "C"
    @State private var isSharp: Bool = true
    @State private var transposeAmount: Int = 0
    
    let sharpKeyNames = ["C", "G", "D", "A", "E", "B", "F#", "C#"]
    let flatKeyNames  = ["C", "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb"]
    
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
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue600)
                        .frame(width: 29.81, height: 29.81)
                        .shadow(color: Color(hex:"2563EB").opacity(0.24), radius: 8.2, x: 0, y: 4.26)
                    Text("1")
                        .textStyle(.headingLgMedium)
                        .foregroundColor(Color.primaryBaseWhite)
                }
                
                HStack(spacing: 3.9) {
                    Circle().fill(Color.primaryGray300).frame(width: 3.61, height: 3.61)
                    Circle().fill(Color.primaryGray300).frame(width: 3.61, height: 3.61)
                    Circle().fill(Color.primaryGray300).frame(width: 3.61, height: 3.61)
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.primaryGray300, lineWidth: 1.06)
                        .frame(width: 29.81, height: 29.81)
                    Text("2")
                        .textStyle(.headingLgMedium)
                        .foregroundColor(Color.primaryGray300)
                }
            }
            .padding(.top, 3.56)
            
            Text("조 인식 결과")
                .textStyle(.headingXLBold)
                .foregroundColor(Color.primaryGray900)
                .padding(.top, 21.63)
            
            Text("인식 결과 확인후 수정사항이 없다면\n다음단계를 진행해주세요.")
                .textStyle(.bodyTextLgRegular)
                .foregroundColor(Color.primaryGray500)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Text(keyText)
                .textStyle(.displayXLSemiBold)
                .frame(width: 282, height: 56)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.primaryGray900)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.primaryGray50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.primaryGray200, lineWidth: 1)
                        )
                )
                .cornerRadius(5)
                .padding(.top, 45)
            
            Button(action: {
                keyText = initialKey
                isSharp = initialIsSharp
                transposeAmount = initialTransposeAmount
            }) {
                HStack(spacing: 1) {
                    Image("reset")
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text("처음으로 되돌리기")
                        .textStyle(.bodyTextLgMedium)
                }
                .foregroundColor(Color.primaryGray600)
                .padding(.horizontal, 12.5)
                .padding(.vertical, 5)
            }
            .background(
                RoundedRectangle(cornerRadius: 200)
                    .fill(Color.primaryGray50)
            )
            .padding(.top, 7)
            
            Spacer()
            
            VStack(alignment: .center, spacing: 16) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("#")
                            .textStyle(.bodyTextXLSemiBold)
                            .foregroundColor(Color.primaryGray600)
                        Text("음을 반음 올림")
                            .textStyle(.bodyTextLgMedium)
                            .foregroundColor(Color.primaryGray400)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            if isSharp && transposeAmount > 0 {
                                transposeAmount -= 1
                            } else {
                                isSharp = true
                                transposeAmount = 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color.primaryGray600)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 11)
                        }
                        
                        Text("\(isSharp ? transposeAmount : 0)")
                            .frame(width: 45.24, height: 27.84)
                            .background(Color.primaryGray50)
                            .cornerRadius(8.7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.7)
                                    .stroke(Color.primaryGray200, lineWidth: 1)
                            )
                            .shadow(color: Color.primaryBaseBlack.opacity(0.10), radius: 3.48, x: 0, y: 0.87)
                        
                        Button(action: {
                            if isSharp {
                                if transposeAmount < 7 {
                                    transposeAmount += 1
                                }
                            } else {
                                isSharp = true
                                transposeAmount = 1
                            }
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color.primaryGray600)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 11)
                        }
                    }
                    .frame(width: 107, height: 33.93)
                    .cornerRadius(8.7)
                    .background(
                        RoundedRectangle(cornerRadius: 8.7)
                            .fill(Color.primaryGray100)
                    )
                }
                .padding(.horizontal, 18)
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("b")
                            .textStyle(.bodyTextXLSemiBold)
                            .foregroundColor(Color.primaryGray600)
                        Text("음을 반음 내림")
                            .textStyle(.bodyTextLgMedium)
                            .foregroundColor(Color.primaryGray400)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            if !isSharp && transposeAmount > 0 {
                                transposeAmount -= 1
                            } else {
                                isSharp = false
                                transposeAmount = 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color.primaryGray600)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 11)
                        }
                        
                        Text("\(!isSharp ? transposeAmount : 0)")
                            .frame(width: 45.24, height: 27.84)
                            .background(Color.primaryGray50)
                            .cornerRadius(8.7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.7)
                                    .stroke(Color.primaryGray200, lineWidth: 1)
                            )
                            .shadow(color: Color.primaryBaseBlack.opacity(0.10), radius: 3.48, x: 0, y: 0.87)
                        
                        Button(action: {
                            if !isSharp {
                                if transposeAmount < 7 {
                                    transposeAmount += 1
                                }
                            } else {
                                isSharp = false
                                transposeAmount = 1
                            }
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color.primaryGray600)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 11)
                        }
                    }
                    .frame(width: 107, height: 33.93)
                    .cornerRadius(8.7)
                    .background(
                        RoundedRectangle(cornerRadius: 8.7)
                            .fill(Color.primaryGray100)
                    )
                }
                .padding(.horizontal, 18)
            }
            .frame(width: 282, height: 111)
            .cornerRadius(5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.primaryGray50)
            )
            
            Spacer()
            
            Button(action: {
                onConfirm(keyText, transposeAmount)
            }) {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.primaryGray300)
                        .frame(height: 1)
                    Text("다음 단계")
                        .textStyle(.headingLgSemiBold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 51)
                        .foregroundColor(.primaryBlue600)
                }
            }
            .padding(.top, 28)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            self.keyText = initialKey
            self.isSharp = initialIsSharp
            self.transposeAmount = initialTransposeAmount
        }
        .onChange(of: isSharp) {
            updateKeyText()
        }
        .onChange(of: transposeAmount) {
            updateKeyText()
        }
    }
    
    private func updateKeyText() {
        let keyNames = isSharp ? sharpKeyNames : flatKeyNames
        if transposeAmount >= 0 && transposeAmount < keyNames.count {
            keyText = keyNames[transposeAmount]
        }
    }
}
