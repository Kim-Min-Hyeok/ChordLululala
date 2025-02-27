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
    var parentContent: UUID?      // 상위 폴더의 cid
    var createdAt: Date
    var modifiedAt: Date
    var lastAccessedAt: Date
    var deletedAt: Date?          // 삭제 시각
    var originalParentId: UUID?   // 복구 폴더(원본 상위 폴더)
    var syncStatus: Bool          // 서버 동기화 여부
    var scoreDetail: UUID?
}

enum ContentType: Int16 {
    case score = 0
    case songList = 1
    case folder = 2
}

extension ContentModel: Hashable {
    static func == (lhs: ContentModel, rhs: ContentModel) -> Bool {
        return lhs.cid == rhs.cid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
}
extension ContentModel {
    init(entity: Content) {
        self.cid = entity.cid ?? UUID()
        self.name = entity.name ?? "Unnamed"
        self.path = entity.path
        self.type = ContentType(rawValue: entity.type) ?? .score
        self.parentContent = entity.parentContent?.cid
        self.createdAt = entity.createdAt ?? Date()
        self.modifiedAt = entity.modifiedAt ?? Date()
        self.lastAccessedAt = entity.lastAccessedAt ?? Date()
        self.deletedAt = entity.deletedAt
        self.originalParentId = entity.originalParentId
        self.syncStatus = entity.syncStatus
        if let scoreDetailEntity = entity.scoreDetail {
            self.scoreDetail = scoreDetailEntity.s_did
        } else {
            self.scoreDetail = nil
        }
    }
}

extension Content {
    func update(from model: ContentModel) {
        self.cid = model.cid
        self.name = model.name
        self.path = model.path
        self.type = model.type.rawValue
        self.createdAt = model.createdAt
        self.modifiedAt = model.modifiedAt
        self.lastAccessedAt = model.lastAccessedAt
        self.deletedAt = model.deletedAt
        self.originalParentId = model.originalParentId
        self.syncStatus = model.syncStatus
        // ScoreDetail 관계 업데이트는 별도 로직으로 관리합니다.
    }
}
