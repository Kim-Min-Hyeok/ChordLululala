////
////  ChordRecognitionManager.swift
////  ChordLululala
////
////  Created by Minhyeok Kim on 5/11/25.
////
//
//import UIKit
//import PDFKit
//import Vision
//
///// 모든 “악보 추출 ↔ 전처리 ↔ OCR ↔ 모델 변환”을 담당합니다.
//class ChordRecognitionManager {
//    static let shared = ChordRecognitionManager()
//    private init() {}
//
//    /// PDF에서 페이지 이미지를 뽑아내는 메서드
//    func extractPages(from pdfURL: URL) -> [UIImage] {
//        guard let doc = PDFDocument(url: pdfURL) else { return [] }
//        return (0..<doc.pageCount).compactMap { idx in
//            guard let page = doc.page(at: idx) else { return nil }
//            let rect = page.bounds(for: .mediaBox)
//            let renderer = UIGraphicsImageRenderer(size: rect.size)
//            return renderer.image { ctx in
//                UIColor.white.setFill()
//                ctx.fill(rect)
//                ctx.cgContext.translateBy(x: 0, y: rect.height)
//                ctx.cgContext.scaleBy(x: 1, y: -1)
//                page.draw(with: .mediaBox, to: ctx.cgContext)
//            }
//        }
//    }
//
//    /// 한 장 이미지에 대해 CVWrapper 전처리 후 Vision OCR → ScoreChordModel 목록 반환
//    private func recognizeChords(in image: UIImage) async -> (UIImage, [ScoreChordModel]) {
//        // 1) OpenCV 전처리
//        let pre = CVWrapper.processScore(image)
//
//        // 2) Vision OCR
//        guard let cg = pre.cgImage else { return (pre, []) }
//        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
//        let req = VNRecognizeTextRequest()
//        req.recognitionLevel = .accurate
//        req.usesLanguageCorrection = false
//        req.recognitionLanguages = ["en-US"]
//
//        var observations: [VNRecognizedTextObservation] = []
//        req.completionHandler = { _, _ in /* noop */ }
//
//        do {
//            try handler.perform([req])
//            observations = req.results as? [VNRecognizedTextObservation] ?? []
//        } catch {
//            print("OCR 실패: \(error)")
//        }
//
//        // 3) bounding-box → 화면 좌표 변환 → 유효한 코드 필터링
//        let imageSize = pre.size
//        var detected: [(String, CGRect)] = []
//        for obs in observations {
//            guard let cand = obs.topCandidates(1).first else { continue }
//            let norm = obs.boundingBox
//            let rect = CGRect(
//                x: norm.origin.x * imageSize.width,
//                y: (1 - norm.origin.y - norm.height) * imageSize.height,
//                width: norm.width * imageSize.width,
//                height: norm.height * imageSize.height
//            )
//            // 한 단어씩 나누고
//            let parts = cand.string.split(separator: " ").map(String.init)
//            let w = rect.width / CGFloat(max(parts.count,1))
//            for (i, word) in parts.enumerated() {
//                if isValidChord(word) {
//                    let box = CGRect(x: rect.minX + CGFloat(i)*w, y: rect.minY, width: w, height: rect.height)
//                    detected.append((word, box))
//                }
//            }
//        }
//
//        // 4) 줄(행) 기준 정렬 → ScoreChordModel 생성
//        let sorted = sortByRowsThenCols(detected)
//        let chords = sorted.map { txt, box in
//            ScoreChordModel(
//                s_cid: UUID(),
//                chord: txt,
//                x: Double(box.minX),
//                y: Double(box.minY),
//                width: Double(box.width),
//                height: Double(box.height)
//            )
//        }
//
//        return (pre, chords)
//    }
//
//    /// 전체 PDF → [ScorePageData] 변환
//    func recognize(from pdfURL: URL) async -> [ScorePageData] {
//        let raws = extractPages(from: pdfURL)
//        var out: [ScorePageData] = []
//        for img in raws {
//            let (proc, chords) = await recognizeChords(in: img)
//            let ids = chords.map { $0.s_cid }
//            let model = ScorePageModel(
//                s_pid: UUID(),
//                rotation: 0,
//                scoreAnnotations: [],
//                scoreMemos: [],
//                scoreChords: ids
//            )
//            out.append(.init(originalImage: img,
//                              processedImage: proc,
//                              pageModel: model,
//                              chords: chords))
//        }
//        return out
//    }
//
//    // ——————————————
//    // MARK: – Helpers
//    private func isValidChord(_ t: String) -> Bool {
//        let pat = #"^[A-G][#b]?(m|maj|min|dim|aug|sus|add)?\d*/?[A-G]?[#b]?$"#
//        return t.range(of: pat, options: .regularExpression) != nil
//    }
//
//    private func sortByRowsThenCols(_ arr: [(String, CGRect)]) -> [(String, CGRect)] {
//        guard !arr.isEmpty else { return [] }
//        let avgH = arr.map{$0.1.height}.reduce(0,+) / CGFloat(arr.count)
//        let vThr = avgH * 1.5
//        var groups: [[(String,CGRect)]] = [[]]
//        var curY = arr[0].1.midY
//        for e in arr.sorted(by:{ $0.1.midY > $1.1.midY }) {
//            if abs(e.1.midY - curY) > vThr {
//                groups.append([])
//                curY = e.1.midY
//            }
//            groups[groups.count-1].append(e)
//        }
//        return groups.flatMap { $0.sorted(by:{ $0.1.midX < $1.1.midX }) }
//    }
//}
//
//private extension CGRect {
//    var midX: CGFloat { minX + width/2 }
//    var midY: CGFloat { minY + height/2 }
//}
