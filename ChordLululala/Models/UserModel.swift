//
//  UserModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

// MARK: - 도메인 모델
struct UserModel {
    let uid: UUID
    var name: String
    var contents: [UUID]   // 관계: 여러 Content 엔티티의 식별자 배열
    var setting: UUID?     // 관계: 단일 Setting 엔티티의 식별자
}

extension UserModel {
    init(entity: User) {
        self.uid = entity.uid ?? UUID()
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
        // 예를 들어, contents는 기존 관계를 모두 제거한 후, model.contents의 UUID에 해당하는 Content 엔티티들을 fetch해서 추가하는 식으로 업데이트해야 합니다.
        // setting도 마찬가지로, model.setting에 해당하는 Setting 엔티티를 찾아서 할당하는 로직을 별도로 구현해야 합니다.
    }
}
