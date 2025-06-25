//
//  ImagePicker.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/11/25.
//

// ScoreView에서 사진 import 용
import SwiftUI
import PhotosUI

/// UIImage를 바로 돌려주는 picker
struct ImagePicker: UIViewControllerRepresentable {
    /// 선택된 이미지
    @Binding var image: UIImage?
    /// 피커를 닫을 바인딩
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let item = results.first?.itemProvider,
                  item.canLoadObject(ofClass: UIImage.self)
            else { return }

            item.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    self.parent.image = object as? UIImage
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
