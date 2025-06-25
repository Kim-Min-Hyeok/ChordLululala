//
//  LanguageDropdownView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/14/25.
//

import SwiftUI

struct LanguageDropdownView: View {
    @Binding var selectedLanguage: AvailableLanguages
    var selectLanguage: (AvailableLanguages) -> Void
    
    @State private var pressedIndex: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(AvailableLanguages.allCases.indices, id: \.self) { index in
                let language = AvailableLanguages.allCases[index]
                
                VStack(spacing: 0) {
                    Button(action: {
                        selectLanguage(language)
                    }) {
                        HStack {
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundStyle(Color.primaryGray800)
                                    .padding(.leading, 29)
                            }
                            
                            Spacer()
                            
                            Text(language.rawValue)
                                .font(.headingLgMedium)
                                .foregroundStyle(Color.primaryBaseBlack)
                                .padding(.trailing, 31)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 53).background(pressedIndex == index ? Color.primaryGray100 : Color.primaryBaseWhite)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in pressedIndex = index }
                            .onEnded { _ in pressedIndex = nil }
                    )
                    
                    if index < AvailableLanguages.allCases.count - 1 {
                        Divider()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.91)
                            .background(Color(hex: "E8E8E8"))
                    }
                }
            }
        }
        .cornerRadius(5)
    }
}
