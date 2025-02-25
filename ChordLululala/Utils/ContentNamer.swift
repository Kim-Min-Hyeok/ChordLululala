//
//  ContentNamer.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import SwiftUI

final class ContentNamer {
    static let shared = ContentNamer()
    
    func generateDuplicateFileName(for model: ContentModel, dashboardContents: DashboardContents) -> String {
        guard model.type != .folder, let originalName = model.name as String? else { return "Unnamed.pdf" }
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        var index = 1
        var newName = "\(baseName) (\(index)).\(ext)"
        if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let oldPath = model.path {
            let originalFileURL = docsURL.appendingPathComponent(oldPath)
            let parentDirectory = originalFileURL.deletingLastPathComponent()
            while FileManager.default.fileExists(atPath: parentDirectory.appendingPathComponent(newName).path) {
                index += 1
                newName = "\(baseName) (\(index)).\(ext)"
            }
        }
        return newName
    }
    
    func generateDuplicateFolderName(for model: ContentModel) -> String {
        let baseName = model.name
        var index = 1
        var newName = "\(baseName) (\(index))"
        let siblings = ContentCoreDataManager.shared.fetchChildrenModels(for: model.parentContent)
        while siblings.contains(where: { $0.name == newName }) {
            index += 1
            newName = "\(baseName) (\(index))"
        }
        return newName
    }
}
