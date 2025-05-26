//
//  ContentModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

enum ContentType: Int16 {
    case score = 0
    case setlist = 1
    case folder = 2
    case scoresOfSetlist = 3
}

import Foundation

// MARK: - 도메인 모델
final class ContentModel: Hashable, Equatable, Identifiable {
    let cid: UUID
    var name: String
    var path: String?
    var type: ContentType
    var parentContent: ContentModel?
    var createdAt: Date
    var modifiedAt: Date
    var lastAccessedAt: Date
    var deletedAt: Date?
    var originalParentId: UUID?
    var syncStatus: Bool
    var isStared: Bool
    var scoreDetail: ScoreDetailModel?
    var scores: [ContentModel]?

    // MARK: - 생성자
    init(
        cid: UUID = UUID(),
        name: String,
        path: String?,
        type: ContentType,
        parentContent: ContentModel? = nil,
        createdAt: Date,
        modifiedAt: Date,
        lastAccessedAt: Date,
        deletedAt: Date? = nil,
        originalParentId: UUID? = nil,
        syncStatus: Bool,
        isStared: Bool,
        scoreDetail: ScoreDetailModel? = nil,
        scores: [ContentModel]? = nil
    ) {
        self.cid = cid
        self.name = name
        self.path = path
        self.type = type
        self.parentContent = parentContent
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.lastAccessedAt = lastAccessedAt
        self.deletedAt = deletedAt
        self.originalParentId = originalParentId
        self.syncStatus = syncStatus
        self.isStared = isStared
        self.scoreDetail = scoreDetail
        self.scores = scores
    }

    // MARK: - Entity → Model 변환
    convenience init(entity: Content) {
        let scoresModels = (entity.scores as? Set<Content>)?.map { ContentModel(entity: $0) } ?? []
        self.init(
            cid: entity.cid ?? UUID(),
            name: entity.name ?? "Unnamed",
            path: entity.path,
            type: ContentType(rawValue: entity.type) ?? .score,
            parentContent: entity.parentContent.map { ContentModel(entity: $0) },
            createdAt: entity.createdAt ?? Date(),
            modifiedAt: entity.modifiedAt ?? Date(),
            lastAccessedAt: entity.lastAccessedAt ?? Date(),
            deletedAt: entity.deletedAt,
            originalParentId: entity.originalParentId,
            syncStatus: entity.syncStatus,
            isStared: entity.isStared,
            scoreDetail: entity.scoreDetail.map { ScoreDetailModel(entity: $0) },
            scores: scoresModels
        )
    }

    // MARK: - Equatable & Hashable
    static func == (lhs: ContentModel, rhs: ContentModel) -> Bool {
        return lhs.cid == rhs.cid && lhs.name == rhs.name && lhs.isStared == rhs.isStared
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
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
        self.isStared = model.isStared
    }
}
