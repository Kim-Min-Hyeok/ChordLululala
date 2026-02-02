//
//  MLKitChordRecognizeManager.swift
//  ChordLululala
//
//  Created by 김민준 on 2/3/26.
//

import UIKit
import MLKitTextRecognition
import MLKitVision
import Combine

final class MLKitChordRecognizeManager {
    static let shared = MLKitChordRecognizeManager()
    private let textRecognizer = TextRecognizer.textRecognizer()
    private init (){}
    
    func recognize(image: UIImage) -> AnyPublisher<(UIImage,[RecognizedChord] ), Never> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success((image, [])))
                return
            }
            
            // MLKit VisionImage 생성
            let visionImage = VisionImage(image: image)
            visionImage.orientation = image.imageOrientation
            
            // 텍스트 인식
            self.textRecognizer.process(visionImage) { result, error in
                if let error = error {
                    print("⚠️ MLKit 인식 오류: \(error)")
                    promise(.success((image, [])))
                    return
                }
                
                guard let result = result else {
                    promise(.success((image, [])))
                    return
                }
                
                // 결과 변환
                var detected: [(String, CGRect)] = []
                for block in result.blocks {
                    for line in block.lines {
                        for element in line.elements {
                            let text = element.text
                            let frame = element.frame
                            detected.append((text, frame))
                        }
                    }
                }
                
                // 필터링 & 정렬 (기존 로직 재사용)
                let valid = detected.filter { self.isValidChord($0.0) }
                let sorted = self.sortByPosition(valid)
                let chords = sorted.map { RecognizedChord(text: $0.0, rect: $0.1) }
                
                promise(.success((image, chords)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    
    // 기존 필터링 로직 복사
    private func isValidChord(_ text: String) -> Bool {
        let p = #"^[A-G](?:[#b])?(?:(?:maj7|maj|min|dim|aug|sus2|sus4|add2|add9|m|M|5|7|6|9|11|13|b5|#9|b9|#11|b13)*)?(?:/[A-G](?:[#b])?)?$"#
        return text.range(of: p, options: .regularExpression) != nil
    }
    
    
    private func sortByPosition(_ items: [(String, CGRect)]) -> [(String, CGRect)] {
        // 기존 ChordRecognizeManager의 sortByPosition 로직 복사
        guard !items.isEmpty else { return [] }
        let avgH = items.map { $0.1.height }.reduce(0, +) / CGFloat(items.count)
        let t = avgH * 1.5
        var groups: [[(String, CGRect)]] = [[]]
        var cy = items[0].1.midY
        for it in items.sorted(by: { $0.1.midY > $1.1.midY }) {
            if abs(it.1.midY - cy) > t {
                groups.append([])
                cy = it.1.midY
            }
            groups[groups.count-1].append(it)
        }
        return groups.flatMap { $0.sorted(by: { $0.1.midX < $1.1.midX }) }
    }
    
    
    
    
}
