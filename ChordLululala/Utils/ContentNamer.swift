//
//  ContentNamer.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import SwiftUI

final class ContentNamer {
    static let shared = ContentNamer()
    
    func generateDuplicateFileName(for content: Content, dashboardContents: DashboardContents) -> String {
        guard content.type != ContentType.folder.rawValue, let originalName = content.name as String? else { return "Copy of Unnamed.pdf" }
        
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        
        let newName = "Copy of \(baseName).\(ext)"
        return newName
    }
    
    func generateDuplicateFolderAndSetlistName(for content: Content) -> String {
        return "Copy of \(String(describing: content.name))"
    }
}
