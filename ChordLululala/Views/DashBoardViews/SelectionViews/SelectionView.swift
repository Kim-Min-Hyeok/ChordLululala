//
//  SelectionView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                }) {
                    Text("전체 선택")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding([.top, .leading], 30)
                Spacer()
                Button(action: {
                    viewModel.isSelectionMode = false
                }) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding([.top, .trailing], 30)
            }
            
            HStack(spacing: 90) {
                SelectionOptionButton(imageName: "paperplane.fill", title: "보내기", action: {
                    print("")
                })
                SelectionOptionButton(imageName: "doc.on.doc", title: "복제", action: {
                    print("")
                })
                SelectionOptionButton(imageName: "arrow.turn.up.left", title: "이동", action: {
                    print("")
                })
                SelectionOptionButton(imageName: "trash.fill", title: "휴지통", action: {
                    viewModel.moveSelectedContentsToTrash()
                })
            }
            
            Spacer()
            Divider()
        }
        .frame(maxWidth: .infinity, maxHeight: 168)
        .background(Color.white)
    }
}
