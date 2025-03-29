//
//  TabBarButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI

struct TabBarButtonView: View {
    var imageName: String
    var title: String
    var action: () -> Void
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            VStack() {
                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 46)
                }
                .frame(width: 79)
                .background(
                    (isSelected ? Color.primaryGray100 : Color.clear)
                        .cornerRadius(29)
                )
                .padding(.top, 9)
                
                Text(title)
                    .textStyle(.headingSmMedium)
                    .foregroundColor(Color.primaryGray900)
                
                Spacer()
            }
            .frame(maxWidth: 79, maxHeight: .infinity)
        }
    }
}
