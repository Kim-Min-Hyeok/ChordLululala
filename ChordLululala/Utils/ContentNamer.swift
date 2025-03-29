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
        guard model.type != .folder, let originalName = model.name as String? else { return "Copy of Unnamed.pdf" }
        
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        
        let newName = "Copy of \(baseName).\(ext)"
        return newName
    }
    
    func generateDuplicateFolderName(for model: ContentModel) -> String {
        return "Copy of \(model.name)"
    }
}
