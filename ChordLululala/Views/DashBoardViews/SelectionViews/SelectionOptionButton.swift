//
//  SelectionOptionButton.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionOptionButton: View {
    let imageName: String
    let title: String
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 10) {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.black)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}
