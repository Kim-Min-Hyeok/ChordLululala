//
//  ScorePageOverView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/24/25.
//

import SwiftUI


struct ScorePageOverView: View {
    var pages: [UIImage]
    var rotations: [Int]
    
    let onClose: () -> Void
    
    var deletePage: (Int) -> Void
    var duplicatePage: (Int) -> Void
    
    let addImage: () -> Void
    let addFile: () -> Void
    let addBlank: () -> Void
    let addStaff: () -> Void
    
    @State private var cellFrames: [Int: CGRect] = [:]
    @State private var selectedIndex: Int? = nil
    
    @State private var isAddPageOptions: Bool = false
    
    @State private var isShowingImagePicker = false
    @State private var pickerSelectedImage: UIImage? = nil
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 160), spacing: 0)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.primaryBaseWhite
                    .contentShape(Rectangle())
                    .frame(width: 693, height: 663)
                    .background(Color.primaryBaseWhite)
                    .cornerRadius(17)
                    .shadow(color: Color.primaryBaseBlack.opacity(0.15), radius: 30)
                    .onTapGesture {
                        onClose()
                    }
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
                .frame(width: 693, height: 36)
                .background(Color.primaryGray50)
                .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 17,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 17
                            )
                        )
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(pages.indices, id: \.self) { idx in
                            ScorePageOverContentView(
                                pageIndex: idx,
                                image: pages[idx],
                                rotate: rotations[idx],
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
//                                        addImage: {
//                                            
//                                        },
//                                        addFile: {
//                                            
//                                        },
                                        addBlank: {
                                            addBlank()
                                        },
                                        addStaff: {
                                            addStaff()
                                        })
                                            .offset(x: -4, y: 77)
                                            .zIndex(1)
                                }
                            }
                    }
                    .padding(.bottom, 215)
                }
                .frame(width: 693)
                .coordinateSpace(name: "scrollArea")
                .onPreferenceChange(CellFrameKey.self) { cellFrames = $0 }
            }
            
            // Overlay the options menu at the selected cell’s frame
            if let i = selectedIndex, let frame = cellFrames[i] {
                PageOptionModalView(
                    deletePage: {
                        deletePage(i)
                        selectedIndex = nil
                    },
                    duplicatePage: {
                        duplicatePage(i)
                        selectedIndex = nil
                    }
                )
                .frame(width: 210)
                .position(x: frame.midX + 18, y: frame.maxY + 75)
                .zIndex(1)
            }
        }
        .frame(width: 800, height: 663)
        .background(Color.clear)
    }
}
