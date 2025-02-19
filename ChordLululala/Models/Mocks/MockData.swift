//
//  MockData.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import Foundation

struct MockData {
    static let sampleFiles: [FileModel] = [
        FileModel(name: "Document1.pdf", location: "/Documents", imageName: "doc.richtext", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FileModel(name: "Document2.pdf", location: "/Documents", imageName: "doc.richtext", isTrash: true, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-86400)), // 어제
        FileModel(name: "Image1.jpg", location: "/Pictures", imageName: "photo", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-172800)), // 2일 전
        FileModel(name: "Music1.mp3", location: "/Music", imageName: "music.note", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FileModel(name: "Video1.mp4", location: "/Videos", imageName: "video", isTrash: true, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-259200)), // 3일 전
        FileModel(name: "Document1.pdf", location: "/Documents", imageName: "doc.richtext", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FileModel(name: "Document2.pdf", location: "/Documents", imageName: "doc.richtext", isTrash: true, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-86400)), // 어제
        FileModel(name: "Image1.jpg", location: "/Pictures", imageName: "photo", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-172800)), // 2일 전
        FileModel(name: "Music1.mp3", location: "/Music", imageName: "music.note", isTrash: false, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FileModel(name: "Video1.mp4", location: "/Videos", imageName: "video", isTrash: true, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-259200)) // 3일 전
    ]
    
    static let sampleFolders: [FolderModel] = [
        FolderModel(name: "Documents", path: "/Documents", files: sampleFiles.filter { $0.location == "/Documents" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FolderModel(name: "Pictures", path: "/Pictures", files: sampleFiles.filter { $0.location == "/Pictures" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-86400)), // 어제
        FolderModel(name: "Music", path: "/Music", files: sampleFiles.filter { $0.location == "/Music" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-172800)), // 2일 전
        FolderModel(name: "Videos", path: "/Videos", files: sampleFiles.filter { $0.location == "/Videos" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-259200)), // 3일 전
        FolderModel(name: "Documents", path: "/Documents", files: sampleFiles.filter { $0.location == "/Documents" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date()),
        FolderModel(name: "Pictures", path: "/Pictures", files: sampleFiles.filter { $0.location == "/Pictures" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-86400)), // 어제
        FolderModel(name: "Music", path: "/Music", files: sampleFiles.filter { $0.location == "/Music" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-172800)), // 2일 전
        FolderModel(name: "Videos", path: "/Videos", files: sampleFiles.filter { $0.location == "/Videos" }, createdDate: Date(), modifiedDate: Date(), accessedDate: Date().addingTimeInterval(-259200)) // 3일 전
    ]
}
