//
//  ScoreForSetlistCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/17/25.
//

import SwiftUI
import QuickLookThumbnailing

struct ScoreForSetlistCellView: View {
    @ObservedObject var viewModel: ScoreSetlistOverViewModel
    @State private var thumbnail: UIImage? = nil
    
    let file: Content
    
    var isSelected: Bool {
        viewModel.isSelected(content: file)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 57, height: 42)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.primaryGray200)
                        .frame(width: 57, height: 42)
                        .overlay(
                            Text("preview")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.primaryGray400)
                        )
                }
            }
            .cornerRadius(2)
            
            Spacer()
                .frame(width: 9)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(file.name ?? "Untitled")
                    .textStyle(.bodyTextXLSemiBold)
                    .foregroundStyle(Color.primaryGray700)
                    .lineLimit(1)
                Text(file.modifiedAt?.dateFormatForList() ?? "")
                    .textStyle(.bodyTextLgMedium)
                    .foregroundStyle(Color.primaryGray500)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Image(isSelected ? "selected2" : "select")
                .resizable()
                .scaledToFit()
                .frame(width: 41, height: 41)
        }
        .clipped()
        .onTapGesture {
            viewModel.toggleSelection(content: file)
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
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
