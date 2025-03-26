//
//  UserModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
struct UserModel {
    let uid: String         // 이제 uid는 외부 제공자의 고유 ID(문자열)로 사용합니다.
    var name: String
    var contents: [UUID]     // 관계: 여러 Content 엔티티의 식별자 배열
    var setting: UUID?       // 관계: 단일 Setting 엔티티의 식별자
}

extension UserModel {
    init(entity: User) {
        // User 엔티티의 uid 속성도 String 타입으로 관리합니다.
        self.uid = entity.uid ?? ""
        self.name = entity.name ?? "Unnamed"
        if let contentsSet = entity.contents as? Set<Content> {
            self.contents = contentsSet.compactMap { $0.cid }
        } else {
            self.contents = []
        }
        self.setting = entity.setting?.sid
    }
}

extension User {
    func update(from model: UserModel) {
        self.uid = model.uid
        self.name = model.name
        // NOTE: contents와 setting 관계는 별도 로직으로 관리해야 합니다.
    }
}
