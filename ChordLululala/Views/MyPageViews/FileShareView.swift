//
//  FileShareView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/15/25.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate class FileActivityItemSource: NSObject, UIActivityItemSource {
    let fileURL: URL
    init(fileURL: URL) { self.fileURL = fileURL }
    
    func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any {
        fileURL
    }
    
    func activityViewController(_ controller: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        fileURL
    }
    
    func activityViewController(_ controller: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        fileURL.lastPathComponent
    }
    
    func activityViewController(_ controller: UIActivityViewController,
                                dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        // public.zip-archive 로 인식
        UTType.zip.identifier
    }
}

// ② ActivityView 교체
struct FileShareView: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let source = FileActivityItemSource(fileURL: fileURL)
        return UIActivityViewController(activityItems: [source], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
