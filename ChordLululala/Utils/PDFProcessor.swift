//
//  PDFProcessor.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import UIKit
import PDFKit

struct PDFProcessor {
    static func extractPages(from pdfURL: URL) -> [UIImage] {
        guard let doc = PDFDocument(url: pdfURL) else { return [] }
        var images: [UIImage] = []
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            let box = page.bounds(for: .mediaBox)
            UIGraphicsBeginImageContext(box.size)
            guard let ctx = UIGraphicsGetCurrentContext() else { continue }
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(box)
            ctx.saveGState()
            ctx.translateBy(x: 0, y: box.height)
            ctx.scaleBy(x: 1, y: -1)
            page.draw(with: .mediaBox, to: ctx)
            ctx.restoreGState()
            if let img = UIGraphicsGetImageFromCurrentImageContext() {
                images.append(img)
            }
            UIGraphicsEndImageContext()
        }
        return images
    }
}
