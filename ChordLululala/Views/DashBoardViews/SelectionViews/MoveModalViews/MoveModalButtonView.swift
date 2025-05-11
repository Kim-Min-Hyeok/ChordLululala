//
//  MoveFolderButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 4/30/25.
//

import SwiftUI

struct MoveFolderButtonView: View {
    let folder: ContentModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 0) {
                    Image("folder_black")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .padding(.leading, 19)
                    Text(folder.name)
                        .textStyle(.bodyTextXLMedium)
                        .foregroundColor(.primaryGray900)
                        .padding(.leading, 7)
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(isSelected ? .primaryGray600 : .clear)
                        .padding(.trailing, 11)
                }
                .padding(.vertical, 5)
                .background(isSelected ? .primaryGray100 : Color.clear)
            }
        }
    }
}
