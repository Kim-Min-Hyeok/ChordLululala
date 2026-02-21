//
//  ShareExtensionView.swift
//  ChordLululalaShareExtension
//
//  Created by Minhyeok Kim on 2/21/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareExtensionView: View {
    weak var extensionContext: NSExtensionContext?

    @State private var fileNames: [String] = []
    @State private var itemProviders: [NSItemProvider] = []
    @State private var isSaving = false
    @State private var saveCompleted = false

    private let appGroupID = "group.com.noteflow.chordlululala"

    var body: some View {
        NavigationView {
            VStack {
                if fileNames.isEmpty && !isSaving {
                    ProgressView("파일 불러오는 중...")
                        .padding()
                } else if saveCompleted {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("업로드 완료")
                            .font(.headline)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(fileNames, id: \.self) { name in
                            HStack {
                                Image(systemName: name.hasSuffix(".pdf") ? "doc.fill" : "photo.fill")
                                    .foregroundColor(.blue)
                                Text(name)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("NoteFlow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("업로드") {
                        saveFiles()
                    }
                    .disabled(isSaving || fileNames.isEmpty)
                }
            }
        }
        .onAppear {
            loadItemProviders()
        }
    }

    private func loadItemProviders() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }

        var providers: [NSItemProvider] = []
        for item in items {
            if let attachments = item.attachments {
                providers.append(contentsOf: attachments)
            }
        }
        itemProviders = providers

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { item, _ in
                    let name: String
                    if let url = item as? URL {
                        name = url.lastPathComponent
                    } else {
                        name = UUID().uuidString + ".pdf"
                    }
                    DispatchQueue.main.async {
                        fileNames.append(name)
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                let suggestedName = provider.suggestedName
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                    let name: String
                    if let url = item as? URL {
                        name = url.lastPathComponent
                    } else if let suggested = suggestedName {
                        name = suggested + ".png"
                    } else {
                        name = UUID().uuidString + ".png"
                    }
                    DispatchQueue.main.async {
                        fileNames.append(name)
                    }
                }
            }
        }
    }

    private func saveFiles() {
        isSaving = true

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        let inboxURL = containerURL.appendingPathComponent("SharedInbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: inboxURL, withIntermediateDirectories: true)

        let group = DispatchGroup()

        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { item, error in
                    defer { group.leave() }
                    guard error == nil else { return }

                    if let url = item as? URL {
                        let destName = uniqueFileName(url.lastPathComponent, in: inboxURL)
                        let dest = inboxURL.appendingPathComponent(destName)
                        try? FileManager.default.copyItem(at: url, to: dest)
                    } else if let data = item as? Data {
                        let name = uniqueFileName(UUID().uuidString + ".pdf", in: inboxURL)
                        let dest = inboxURL.appendingPathComponent(name)
                        try? data.write(to: dest)
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    defer { group.leave() }
                    guard error == nil else { return }

                    if let url = item as? URL {
                        let destName = uniqueFileName(url.lastPathComponent, in: inboxURL)
                        let dest = inboxURL.appendingPathComponent(destName)
                        try? FileManager.default.copyItem(at: url, to: dest)
                    } else if let image = item as? UIImage,
                              let data = image.pngData() {
                        let suggestedName = provider.suggestedName ?? UUID().uuidString
                        let name = uniqueFileName(suggestedName + ".png", in: inboxURL)
                        let dest = inboxURL.appendingPathComponent(name)
                        try? data.write(to: dest)
                    } else if let data = item as? Data {
                        let suggestedName = provider.suggestedName ?? UUID().uuidString
                        let name = uniqueFileName(suggestedName + ".png", in: inboxURL)
                        let dest = inboxURL.appendingPathComponent(name)
                        try? data.write(to: dest)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            saveCompleted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }

    private func uniqueFileName(_ name: String, in directory: URL) -> String {
        let fileManager = FileManager.default
        let baseName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        var candidate = name
        var counter = 1
        while fileManager.fileExists(atPath: directory.appendingPathComponent(candidate).path) {
            candidate = ext.isEmpty ? "\(baseName)_\(counter)" : "\(baseName)_\(counter).\(ext)"
            counter += 1
        }
        return candidate
    }
}
