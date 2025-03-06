//
//  PDFPicker.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct FilePicker: UIViewControllerRepresentable {
    var onPicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.png, UTType.jpeg], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPicked: (URL) -> Void
        
        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let originalURL = urls.first else { return }
            
            let ext = originalURL.pathExtension.lowercased()
            
            if ext == "pdf" {
                // PDF 파일이면 그대로 전달
                onPicked(originalURL)
            } else if ext == "png" || ext == "jpg" || ext == "jpeg" {
                // 이미지 파일을 PDF로 변환
                guard let image = UIImage(contentsOfFile: originalURL.path) else {
                    print("이미지 로드 실패")
                    return
                }
                
                let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
                let pdfData = pdfRenderer.pdfData { context in
                    context.beginPage()
                    image.draw(in: CGRect(origin: .zero, size: image.size))
                }
                
                // 임시 파일에 PDF 데이터 저장
                let tempDir = FileManager.default.temporaryDirectory
                let pdfURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
                do {
                    try pdfData.write(to: pdfURL)
                    onPicked(pdfURL)
                } catch {
                    print("PDF 데이터 쓰기 에러: \(error)")
                }
            } else {
                print("지원되지 않는 파일 타입입니다.")
            }
        }
    }
}
