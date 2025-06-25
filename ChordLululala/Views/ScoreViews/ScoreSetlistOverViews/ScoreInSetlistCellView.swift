//
//  ScoreCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/13/25.
//

import SwiftUI
import QuickLookThumbnailing

struct ScoreInSelistCellView: View {
    @State private var thumbnail: UIImage? = nil
    
    let score: Content
    
    let keyTransformation: () -> Void
    let deleteScore: () -> Void
    let gotoScoreDetail: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                deleteScore()
            }) {
                VStack(alignment: .center) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.primaryGray400)
                        .frame(width: 12, height: 12)
                }
                .frame(width: 34, height: 34)
            }
            
            HStack {
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
                    Text(score.name ?? "Untitled")
                        .textStyle(.bodyTextXLSemiBold)
                        .foregroundStyle(Color.primaryGray700)
                        .lineLimit(1)
                    Text(score.modifiedAt?.dateFormatForList() ?? "")
                        .textStyle(.bodyTextLgMedium)
                        .foregroundStyle(Color.primaryGray500)
                }
            }
            .onTapGesture {
                gotoScoreDetail()
            }
            
            Spacer()
                .frame(width: 9)
            
            Spacer()
            
            Text("키변환")
                .textStyle(.bodyTextLgSemiBold)
                .foregroundStyle(Color.primaryBlue600)
                .padding(.horizontal, 22)
                .padding(.vertical, 4)
                .contentShape(Rectangle()) // 정확한 탭 영역 설정
                .onTapGesture {
                    keyTransformation()
                }
            
//            Button(action: {
//                deleteScore()
//            }) {
//                VStack(alignment: .center) {
//                    Image(systemName: "xmark")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 12, height: 12)
//                }
//                .frame(width: 34, height: 34)
//            }
//            .padding(.leading, 22)
        }
        .clipped()
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        guard let relativePath = score.path, !relativePath.isEmpty,
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
