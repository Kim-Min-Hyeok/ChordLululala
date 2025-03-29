//
//  PhotoPicker.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    var onPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onPicked: (URL) -> Void
        
        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let itemProvider = results.first?.itemProvider,
                  itemProvider.canLoadObject(ofClass: UIImage.self) else {
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
                            self.onPicked(pdfURL)
                        }
                    } catch {
                        print("PDF 저장 실패: \(error)")
                    }
                }
            }
        }
    }
}
