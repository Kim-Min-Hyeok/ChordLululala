//
//  ScorePageOverView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct ScorePageOverView: View {
    @ObservedObject var viewModel: ScorePageOverViewModel
    let onClose: () -> Void
    let pages: [UIImage]
    
    @State private var cellFrames: [Int: CGRect] = [:]
    @State private var selectedIndex: Int? = nil
    
    @State private var isAddPageOptions: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 160), spacing: 0)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Text("닫기")
                            .foregroundColor(Color.primaryBlue600)
                            .textStyle(.headingSmMedium)
                            .padding(.trailing, 23)
                            .padding(.vertical, 7)
                    }
                }
                .frame(height: 36)
                .background(Color.primaryGray50)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(pages.indices, id: \.self) { idx in
                            ScorePageOverContentView(
                                pageIndex: idx + 1,
                                image: pages[idx],
                                onToggleOptions: { i in
                                    isAddPageOptions = false
                                    selectedIndex = (selectedIndex == i ? nil : i)
                                }
                            )
                        }
                        PageAddButtonView(
                            toggleOptions: {
                                isAddPageOptions.toggle()
                                selectedIndex = nil
                            })
                            .overlay(alignment: .bottom) {
                                if isAddPageOptions && selectedIndex == nil {
                                    PageAddModalView(
                                        addImage: {
                                            
                                        },
                                        addFile: {
                                            
                                        },
                                        addBlank: {
                                            
                                        },
                                        addStaff: {
                                            
                                        })
                                            .offset(x: -4, y: 149)
                                            .zIndex(1)
                                }
                            }
                    }
                    .coordinateSpace(name: "GridSpace")
                    .onPreferenceChange(CellFrameKey.self) { cellFrames = $0 }
                }
            }
            
            // Overlay the options menu at the selected cell’s frame
            if let i = selectedIndex, let frame = cellFrames[i] {
                PageOptionModalView(
                    deletePage: {
                        // TODO: 페이지 삭제
                        selectedIndex = nil
                    },
                    duplicatePage: {
                        // TODO: 페이지 복제
                        selectedIndex = nil
                    }
                )
                .frame(width: 210)
                .position(x: frame.midX - 29, y: frame.maxY + 75)
                .zIndex(1)
            }
        }
        .frame(width: 693, height: 663)
        .background(Color.primaryBaseWhite)
        .cornerRadius(17)
        .shadow(color: Color.primaryBaseBlack.opacity(0.15), radius: 30)
    }
}
