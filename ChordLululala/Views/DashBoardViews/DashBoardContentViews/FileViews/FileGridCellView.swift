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
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        VStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 114)
            } else {
                // 썸네일이 아직 로드되지 않았으면 placeholder 표시
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 114)
                    .overlay(Text("Loading").font(.caption))
            }
            Spacer()
            HStack {
                Text(file.name ?? "Unnamed")
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.bottom, 1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 146, maxHeight: 146)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(9)
        .onAppear {
            loadThumbnail()
        }
    }
    
    func loadThumbnail() {
        // file.path가 nil이 아니면 언랩하여 사용
        guard let filePath = file.path, !filePath.isEmpty else {
            print("파일 경로가 없습니다.")
            return
        }
        let fileURL = URL(fileURLWithPath: filePath)
        // 원하는 썸네일 사이즈와 스케일 설정
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: CGSize(width: 200, height: 200), scale: UIScreen.main.scale, representationTypes: .thumbnail)
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { (thumbnailRep, error) in
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
