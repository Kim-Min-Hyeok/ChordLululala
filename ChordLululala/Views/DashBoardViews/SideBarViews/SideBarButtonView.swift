//
//  SideBarButtonView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct SidebarButtonView: View {
    var imageName: String
    var title: String
    var action: () -> Void
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            HStack() {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46, height: 46)
                    .padding(.leading, 14)
                
                Text(title)
                    .textStyle(.headingSmMedium)
                    .foregroundColor(Color.primaryGray900)
                    .padding(.leading, 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 46.06, maxHeight: 46.06)
            .background(isSelected ? Color.primaryGray100 : Color.clear)
        }
    }
}
