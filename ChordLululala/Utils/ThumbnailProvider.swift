//
//  ThumbnailProvider.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI
import Combine
import QuickLookThumbnailing

// pdf의 썸네일 가져오기
final class ThumbnailProvider {
    static let shared = ThumbnailProvider()
    
    /// relativePath: Documents 폴더 기준의 상대 경로
    func generateThumbnail(for relativePath: String) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { promise in
            guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                promise(.success(nil))
                return
            }
            let fileURL = docsURL.appendingPathComponent(relativePath)
            let request = QLThumbnailGenerator.Request(
                fileAt: fileURL,
                size: CGSize(width: 200, height: 200),
                scale: UIScreen.main.scale,
                representationTypes: .thumbnail
            )
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnailRep, error in
                if let thumbnailRep = thumbnailRep {
                    promise(.success(thumbnailRep.uiImage))
                } else {
                    print("썸네일 생성 실패: \(String(describing: error))")
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
