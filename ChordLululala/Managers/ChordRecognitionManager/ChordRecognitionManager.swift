//
//  ChordRecognitionManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import UIKit
import Vision
import Combine

struct RecognizedChord {
  let text: String
  let rect: CGRect
}

/// OpenCV 전처리 + Vision OCR
final class ChordRecognizeManager {
    static let shared = ChordRecognizeManager()
    private init() {}

    func recognize(image: UIImage) -> AnyPublisher<(UIImage, [RecognizedChord]), Never> {
      Future { promise in
        // 1) OpenCV 전처리
        let processed = CVWrapper.processScore(image)
        guard let cg = processed.cgImage else {
          promise(.success((processed, [])))
          return
        }

        // 2) OCR
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        let request = VNRecognizeTextRequest { req, _ in
          var detected: [(String, CGRect)] = []

          if let obs = req.results as? [VNRecognizedTextObservation] {
            let sz = processed.size
            for o in obs {
              guard let candidate = o.topCandidates(1).first else { continue }
              let bb = o.boundingBox
              let rect = CGRect(
                x: bb.minX * sz.width,
                y: (1 - bb.maxY) * sz.height,
                width: bb.width * sz.width,
                height: bb.height * sz.height
              )
              // splitText는 "Amaj7→ [("A","rect1"),("maj7","rect2")]" 처럼 나눠준다고 가정
              detected.append(contentsOf: self.splitText(candidate.string, in: rect))
            }
          }

          // 필터링 & 정렬
          let valid   = detected.filter { self.isValidChord($0.0) }
          let sorted  = self.sortByPosition(valid)

          // RecognizedChord 배열로 변환
          let chords = sorted.map { RecognizedChord(text: $0.0, rect: $0.1) }
          promise(.success((processed, chords)))
        }

        request.recognitionLevel       = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages   = [ "en-US" ]

        DispatchQueue.global(qos: .userInitiated).async {
          try? handler.perform([request])
        }
      }
      .eraseToAnyPublisher()
    }

    private func isValidChord(_ text: String) -> Bool {
        let p = #"^[A-G](?:[#b])?(?:(?:maj7|maj|min|dim|aug|sus2|sus4|add2|add9|m|M|5|7|6|9|11|13|b5|#9|b9|#11|b13)*)?(?:/[A-G](?:[#b])?)?$"#
        return text.range(of: p, options: .regularExpression) != nil
    }
    
    private func splitText(_ text: String, in box: CGRect) -> [(String, CGRect)] {
        let parts = text.split(separator: " ").map(String.init)
        guard parts.count > 1 else { return [(text, box)] }
        let w = box.width / CGFloat(parts.count)
        return parts.enumerated().map { i, str in
            (str, CGRect(x: box.origin.x + CGFloat(i)*w,
                         y: box.origin.y,
                         width: w,
                         height: box.height))
        }
    }
    private func sortByPosition(_ items: [(String, CGRect)]) -> [(String, CGRect)] {
        guard !items.isEmpty else { return [] }
        let avgH = items.map { $0.1.height }.reduce(0, +) / CGFloat(items.count)
        let t    = avgH * 1.5
        var groups: [[(String, CGRect)]] = [[]]
        var cy = items[0].1.midY
        for it in items.sorted(by: { $0.1.midY > $1.1.midY }) {
            if abs(it.1.midY - cy) > t {
                groups.append([]); cy = it.1.midY
            }
            groups[groups.count-1].append(it)
        }
        return groups.flatMap { $0.sorted(by: { $0.1.midX < $1.1.midX }) }
    }
}

extension CGRect {
    var midX: CGFloat { origin.x + width/2 }
    var midY: CGFloat { origin.y + height/2 }
}
