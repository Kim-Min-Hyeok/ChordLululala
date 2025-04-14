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
            VStack(spacing: 3) {
                Image(imageName)
                    .resizable()
                    .frame(width: 39, height: 39)
                    .foregroundColor(.black)
                Text(title)
                    .textStyle(.headingSmMedium)
                    .foregroundColor(title == "휴지통" ? Color.supportingRed500 : Color.primaryGray900)
            }
        }
    }
}
