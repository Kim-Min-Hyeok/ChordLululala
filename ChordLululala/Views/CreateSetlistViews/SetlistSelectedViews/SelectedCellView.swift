//
//  SelectedCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI

struct SelectedCellView: View {
    @EnvironmentObject var viewModel: CreateSetlistViewModel
    @State private var thumbnail: UIImage? = nil
    
    let file: ContentModel
    
    var isSelected: Bool {
        viewModel.isSelected(content: file)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                viewModel.unselectContent(content: file)
            }) {
                Image("unselect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .padding(.leading, 14)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(file.name)
                    .textStyle(.bodyTextXLSemiBold)
                    .foregroundStyle(Color.primaryGray800)
                Text(file.modifiedAt.dateFormatForList())
                    .textStyle(.bodyTextLgRegular)
                    .foregroundStyle(Color.primaryGray600)
                    .padding(.top, 3)
            }
            .padding(.leading, 22)
            
            Spacer()
        }
        .frame(height: 65)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.unselectContent(content: file)
        }
    }
}
