//
//  SelectionView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/23/25.
//

import SwiftUI

struct SelectionView: View {
    
    var onSelectAll: (() -> Void)?
    var onComplete: (() -> Void)?
    var onSend: (() -> Void)?
    var onDuplicate: (() -> Void)?
    var onMove: (() -> Void)?
    var onTrash: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onSelectAll?()
                }) {
                    Text("전체 선택")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding([.top, .leading], 30)
                Spacer()
                Button(action: {
                    // 완료 버튼 눌렀을 때 선택 모드 종료
                    onComplete?()
                }) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding([.top, .trailing], 30)
            }
            
            HStack(spacing: 90) {
                SelectionOptionButton(imageName: "paperplane.fill", title: "보내기", action: onSend)
                SelectionOptionButton(imageName: "doc.on.doc", title: "복제", action: onDuplicate)
                SelectionOptionButton(imageName: "arrow.turn.up.left", title: "이동", action: onMove)
                SelectionOptionButton(imageName: "trash.fill", title: "휴지통", action: onTrash)
            }
            
            Spacer()
            Divider()
        }
        .frame(maxWidth: .infinity, maxHeight: 168)
        .background(Color.white)
    }
}
