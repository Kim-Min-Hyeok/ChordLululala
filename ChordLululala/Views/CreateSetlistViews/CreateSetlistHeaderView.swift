//
//  CreateSetlistHeaderView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI

struct CreateSetlistHeaderView: View {
    @EnvironmentObject var dashBoardViewModel: DashBoardViewModel
    @EnvironmentObject var viewModel: CreateSetlistViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.primaryBaseWhite.opacity(0.9))
                .blur(radius: 2)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)

            // 셋리스트 이름 중앙 정렬용 ZStack
            ZStack {
                HStack {
                    Button(action: {
                        dashBoardViewModel.dashboardContents = .setlist
                    }) {
                        Image("arrow_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36)
                            .foregroundStyle(Color.primaryGray900)
                            .padding(.leading, dashBoardViewModel.isLandscape ? 22 : 46)
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        guard let currentParent = dashBoardViewModel.currentParent else { return }
                        viewModel.createSetlist(dashBoardViewModel.nameOfSetlistCreating, currentParent: currentParent) {
                            dashBoardViewModel.goToSetlistPreservingFolder()
                        }
                    }) {
                        Text("생성")
                            .textStyle(.headingLgMedium)
                            .foregroundStyle(viewModel.selectedContents.isEmpty ? Color.primaryGray400 : Color.primaryGray900)
                            .frame(width: 48, height: 36)
                    }
                    .disabled(viewModel.selectedContents.isEmpty)
                    .padding(.trailing, 48)
                }

                Text(dashBoardViewModel.nameOfSetlistCreating)
                    .textStyle(.headingLgSemiBold)
                    .foregroundStyle(Color.primaryGray900)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 46)
            .padding(.bottom, 9)
        }
        .frame(maxWidth: .infinity, maxHeight: 91)
    }
}

