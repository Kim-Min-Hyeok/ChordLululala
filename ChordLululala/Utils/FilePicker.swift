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
    var onStart: (Int) -> Void
    var onFileReady: (URL) -> Void
    var onComplete: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.png, UTType.jpeg], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onStart: onStart, onFileReady: onFileReady, onComplete: onComplete)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
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

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard !urls.isEmpty else { return }

            onStart(urls.count)

            for url in urls {
                onFileReady(url)
            }

            onComplete()
        }
    }
}
