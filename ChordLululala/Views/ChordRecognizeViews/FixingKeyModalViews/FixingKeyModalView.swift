//
//  FixingKeyModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/29/25.
//

import SwiftUI

struct FixingKeyModalView: View {
    let onConfirm: (_ keyText: String, _ transposeAmount: Int) -> Void
    let onCancel: () -> Void
    let title: String
    let description: String
    let subtitle: String
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
            
            Text(title)
                .textStyle(.headingMdSemiBold)
                .foregroundColor(Color.primaryGray900)
                .padding(.top, 30)
            
            Text(description)
                .textStyle(.bodyTextLgRegular)
                .foregroundColor(Color.primaryGray500)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Text(subtitle)
                .textStyle(.bodyTextLgMedium)
                .foregroundColor(Color.primaryGray800)
                .padding(.top, 39)
            
            Text("\(keyText) key")
                .textStyle(.headingLgSemiBold)
                .frame(width: 224, height: 46)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.primaryGray900)
                .background(Color.primaryGray100)
                .cornerRadius(5)
                .padding(.top, 8)
            
            HStack(spacing: 0) {
                // ♭ 버튼
                Button(action: { isSharp = false }) {
                    Text("♭")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            (isSharp
                             ? AnyShapeStyle(Color.primaryBaseWhite)
                             : AnyShapeStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryGray500, Color.primaryGray600]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                             )
                            )
                        )
                        .foregroundColor(isSharp ? Color.primaryGray400 : Color.primaryBaseWhite)
                        .overlay(
                            isSharp ?
                            RoundedBorderShape(corners: [.topLeft, .bottomLeft], radius: 6, lineWidth: 1)
                                .fill(Color.primaryGray400)
                            : nil
                        )
                }
                
                // # 버튼
                Button(action: { isSharp = true }) {
                    Text("#")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            (isSharp
                             ? AnyShapeStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryGray500, Color.primaryGray600]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                             )
                             : AnyShapeStyle(Color.primaryBaseWhite)
                            )
                        )
                        .foregroundColor(isSharp ? Color.primaryBaseWhite : Color.primaryGray400)
                        .overlay(
                            !isSharp ?
                            RoundedBorderShape(corners: [.topRight, .bottomRight], radius: 6, lineWidth: 1)
                                .fill(Color.primaryGray400)
                            : nil
                        )
                }
            }
            .frame(width: 227)
            .background(Color.primaryBaseWhite)
            .cornerRadius(6)
            .padding(.top, 39)
            
            
            
            HStack(spacing: 8) {
                
                Button(action: {
                    if transposeAmount > 0 {
                        transposeAmount -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primaryGray700)
                        .padding(.horizontal, 19)
                        .padding(.vertical, 11)
                }
                
                Text("\(transposeAmount)")
                    .frame(width: 92, height: 42)
                    .foregroundColor(Color.primaryBaseBlack)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6.32)
                            .stroke(Color.primaryGray100, lineWidth: 1)
                    )
                
                Button(action: {
                    if transposeAmount < 7 {
                        transposeAmount += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primaryGray700)
                        .padding(.horizontal, 19)
                        .padding(.vertical, 11)
                }
            }
            .padding(.top, 8)
            
            Button(action: {
                onConfirm(keyText, transposeAmount)
            }) {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.primaryGray300)
                        .frame(height: 1)
                    Text("설정 완료")
                        .textStyle(.headingLgSemiBold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 51)
                        .foregroundColor(.primaryBlue600)
                }
            }
            .padding(.top, 37)
        }
        .frame(maxWidth: 321)
        .background(Color.primaryBaseWhite)
        .cornerRadius(10)
        .shadow(radius: 30)
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
