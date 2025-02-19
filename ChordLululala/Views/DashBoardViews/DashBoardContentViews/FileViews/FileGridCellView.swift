//
//  FileGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileGridCellView: View {
    let file: FileModel
    var body: some View {
        VStack() {
            file.image
                .resizable()
                .frame(height: 114)
                .foregroundColor(.black)
            Spacer()
            HStack() {
                Text(file.name)
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.bottom, 1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 146, maxHeight: 146)
        .background(Color.gray)
        .cornerRadius(9)
    }
}
