//
//  CreateSetlistView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/21/25.
//

import SwiftUI

struct CreateSetlistView: View {
    @EnvironmentObject var dashBoardViewModel: DashBoardViewModel
    @StateObject private var viewModel = CreateSetlistViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CreateSetlistHeaderView()
                .shadow(color: Color.primaryBaseBlack.opacity(0.18), radius: 15, x: 0, y: 10)
            
            GeometryReader { geometry in
                Group {
                    if dashBoardViewModel.isLandscape {
                        HStack(alignment: .center, spacing: 0) {
                            VStack(spacing: 0) {
                                SetlistCandidateSearchView()
                                SetlistCandidateView()
                                    .padding(.top, 38)
                            }
                            .frame(maxWidth: geometry.size.width * (539 / 1194), maxHeight: .infinity)
                            
                            Spacer()
                            
                            Divider()
                                .frame(maxWidth: 1, maxHeight: .infinity)
                                .background(Color(hex: "D6D6D6"))
                                .padding(.top, 48)
                                .padding(.bottom, 33)
                                .padding(.trailing, 13)
                            
                            Spacer()
                            
                            SetlistSelectedView()
                                .frame(maxWidth: geometry.size.width * (506 / 1194), maxHeight: .infinity)
                        }
                        .padding(.horizontal, 48)
                        .padding(.top, 45)
                        .padding(.bottom, 33)
                    } else {
                        VStack(spacing: 0) {
                            SetlistCandidateSearchView()
                                .padding(.top, 35)
                            
                            SetlistCandidateView()
                                .frame(maxWidth: .infinity, minHeight: geometry.size.height * (390 / 1194))
                                .padding(.top, 49)
                            
                            Spacer()
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 1)
                                .background(Color(hex: "D6D6D6"))
                                .padding(.leading, 270)
                                .padding(.trailing, 270)
                            Spacer()
                            SetlistSelectedView()
                                .frame(maxWidth: .infinity, minHeight: geometry.size.height * (315 / 1194))
                        }
                        .padding(.horizontal, 46)
                    }
                }
            }
        }
        .background(Color.primaryGray50)
        .environmentObject(viewModel)
        .navigationBarHidden(true)
    }
}
