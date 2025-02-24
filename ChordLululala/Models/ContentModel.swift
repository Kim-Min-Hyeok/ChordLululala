//
//  ContentModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// 도메인 모델
struct ContentModel {
    let cid: UUID
    var name: String
    var path: String?             // FileManager 내의 경로
    var type: ContentType         // score(0), song_list(1), folder(2)
    var category: ContentCategory // score(0), song_list(1), trash(2)
    var parent: UUID?           // 상위 폴더의 cid
    var createdAt: Date
    var modifiedAt: Date
    var lastAccessedAt: Date
    var deletedAt: Date?          // 삭제 시각
    var isTrash: Bool             // 휴지통 여부
    var originalParentId: UUID?   // 복구 폴더(원본 상위 폴더)
    var syncStatus: Bool          // 서버 동기화 여부
    var s_dids: [UUID]?           // 연관된 UUID 배열 (옵션)
}

enum ContentType: Int16 {
    case score = 0
    case songList = 1
    case folder = 2
}

enum ContentCategory: Int16 {
    case score = 0
    case songList = 1
    case trash = 2
}

// CoreData Entity(Content) -> 도메인 모델(ContentModel) Mapping
extension ContentModel {
    init(entity: Content) {
        self.cid = entity.cid ?? UUID()
        self.name = entity.name ?? "Unnamed"
        self.path = entity.path
        self.type = ContentType(rawValue: entity.type) ?? .score
        self.category = ContentCategory(rawValue: entity.category) ?? .score
        self.parent = entity.parent
        self.createdAt = entity.createdAt ?? Date()
        self.modifiedAt = entity.modifiedAt ?? Date()
        self.lastAccessedAt = entity.lastAccessedAt ?? Date()
        self.deletedAt = entity.deletedAt
        self.isTrash = entity.isTrash
        self.originalParentId = entity.originalParentId
        self.syncStatus = entity.syncStatus
        if let array = entity.s_dids as? [UUID] {
            self.s_dids = array
        } else {
            self.s_dids = nil
        }
    }
}

// 도메인 모델(ContentModel) -> CoreData Entity(Content) 업데이트
extension Content {
    func update(from model: ContentModel) {
        self.cid = model.cid
        self.name = model.name
        self.path = model.path
        self.type = model.type.rawValue
        self.category = model.category.rawValue
        self.parent = model.parent
        self.createdAt = model.createdAt
        self.modifiedAt = model.modifiedAt
        self.lastAccessedAt = model.lastAccessedAt
        self.deletedAt = model.deletedAt
        self.isTrash = model.isTrash
        self.originalParentId = model.originalParentId
        self.syncStatus = model.syncStatus
        self.s_dids = model.s_dids as NSArray?
    }
}
