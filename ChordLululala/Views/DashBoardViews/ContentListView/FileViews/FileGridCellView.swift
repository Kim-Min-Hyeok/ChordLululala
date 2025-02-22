//
//  FileGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI
import QuickLookThumbnailing

struct FileGridCellView: View {
    let file: Content
    // onEllipsisTapped: 셀의 전체 global frame을 전달 (모달 위치 계산에 사용)
    var onEllipsisTapped: (CGRect) -> Void
    
    @State private var thumbnail: UIImage? = nil
    @State private var cellFrame: CGRect = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 영역 (고정 높이 201, image가 꽉 차게)
            Group {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 114)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 114)
                        .overlay(Text("Loading").font(.caption))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // 파일 셀 전체 탭 액션 필요 시 여기에 구현 가능
            }
            
            // 텍스트 + 버튼 영역 (고정 높이 32)
            HStack {
                Text(file.name ?? "Unnamed")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    onEllipsisTapped(cellFrame)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .frame(width: 24, height: 24)
            }
            .frame(height: 32)
            .background(Color.blue)
        }
        .frame(height: 114 + 32)
        .background(Color.red) // 셀의 배경 색상(테스트용)
        .cornerRadius(9)
        .onAppear {
            loadThumbnail()
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    self.cellFrame = geo.frame(in: .global)
                }
            }
        )
    }
    
    func loadThumbnail() {
        guard let relativePath = file.path, !relativePath.isEmpty,
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("파일 경로 없음")
            return
        }
        let fileURL = docsURL.appendingPathComponent(relativePath)
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: CGSize(width: 201, height: 114),
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnailRep, error in
            if let thumbnailRep = thumbnailRep {
                DispatchQueue.main.async {
                    self.thumbnail = thumbnailRep.uiImage
                }
            } else {
                print("썸네일 생성 실패: \(String(describing: error))")
            }
        }
    }
}
