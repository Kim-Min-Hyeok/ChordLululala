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
    
    // 재사용성이 없어보여서,,, 분리하면 쓸데 없는 코드가 많아질 것 같아서 여기에 선언함.
    func loadThumbnail() {
        guard let relativePath = file.path, !relativePath.isEmpty,
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("상대 경로가 없거나 Documents 경로를 찾을 수 없음")
            return
        }
        
        let fileURL = docsURL.appendingPathComponent(relativePath)
        print("썸네일 생성할 파일 URL: \(fileURL)")
        
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
