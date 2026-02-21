//
//  PhotoPicker.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    var onStart: (Int) -> Void
    var onFileReady: (URL) -> Void
    var onComplete: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onStart: onStart, onFileReady: onFileReady, onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onStart: (Int) -> Void
        var onFileReady: (URL) -> Void
        var onComplete: () -> Void

        init(
            onStart: @escaping (Int) -> Void,
            onFileReady: @escaping (URL) -> Void,
            onComplete: @escaping () -> Void
        ) {
            self.onStart = onStart
            self.onFileReady = onFileReady
            self.onComplete = onComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            DispatchQueue.main.async {
                self.onStart(results.count)
            }

            processNextResult(results: results, index: 0)
        }

        private func processNextResult(results: [PHPickerResult], index: Int) {
            guard index < results.count else {
                DispatchQueue.main.async {
                    self.onComplete()
                }
                return
            }

            let itemProvider = results[index].itemProvider
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                processNextResult(results: results, index: index + 1)
                return
            }

            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
                    let pdfData = pdfRenderer.pdfData { context in
                        context.beginPage()
                        image.draw(in: CGRect(origin: .zero, size: image.size))
                    }

                    let tempDir = FileManager.default.temporaryDirectory
                    let pdfURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
                    do {
                        try pdfData.write(to: pdfURL)
                        DispatchQueue.main.async {
                            self.onFileReady(pdfURL)
                        }
                    } catch {
                        print("PDF 저장 실패: \(error)")
                    }
                }

                self.processNextResult(results: results, index: index + 1)
            }
        }
    }
}
