//
//  SetlistSelectedView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SetlistSelectedView: View {
    @EnvironmentObject var dashBoardViewModel: DashBoardViewModel
    @EnvironmentObject var viewModel: CreateSetlistViewModel
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("\(viewModel.selectedContents.count)개 선택됨")
                    .textStyle(.bodyTextLgMedium)
                    .foregroundStyle(viewModel.selectedContents.isEmpty ? Color.primaryGray300 : Color.primaryGray600)
                    .padding([.top, .trailing], 13)
            }
            
            if viewModel.selectedContents.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image("plus_black")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 19.5)
                    Text("이곳에 파일을 끌어다 넣어주세요.")
                        .textStyle(.headingMdSemiBold)
                        .foregroundStyle(Color.primaryGray600)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.selectedContents, id: \.objectID) { content in
                        SelectedCellView(file: content)
                            .frame(height: 65)
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color.primaryBaseWhite)
                                    .frame(height: 65)
                            )
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                    }
                    .onMove(perform: viewModel.moveSelectedContent)
                    .onInsert(of: [UTType.plainText]) { index, providers in
                        _ = viewModel.selectByDragAndDrop(providers: providers, at: index)
                    }

                }
                .listRowSpacing(13)
                .listStyle(PlainListStyle())
                .environment(\.editMode, .constant(.active))
                .padding(.top, 18)
                .padding(.horizontal, dashBoardViewModel.isLandscape ? 13 : 33)
                .onDrop(of: [UTType.plainText], isTargeted: .constant(false)) { providers in
                    viewModel.selectByDragAndDrop(providers: providers, at: viewModel.selectedContents.count)
                }
            }
        }
        .background(Color.primaryGray100)
        .cornerRadius(14)
        .onDrop(of: [UTType.plainText], isTargeted: .constant(false)) { providers in
            viewModel.selectByDragAndDrop(providers: providers, at: viewModel.selectedContents.count)
        }
    }
}
