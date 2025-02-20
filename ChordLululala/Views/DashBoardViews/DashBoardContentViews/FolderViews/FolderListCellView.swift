//
//  FolderListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderListCellView: View {
    let folder: FolderModel
    var body: some View {
        VStack(){
            HStack(spacing: 2) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 53, height: 53)
                    .foregroundColor(.black)
                Text(folder.name)
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
            }
            Divider()
        }
        .background(Color.clear)
        .frame(height: 53)
    }
}
