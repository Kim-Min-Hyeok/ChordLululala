//
//  UserManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/22/25.
//

import Foundation
import CoreData

final class UserManager {
    static let shared = UserManager()
    private let context = CoreDataManager.shared.context

    /// 외부 제공자의 고유 ID(providerId)를 uid로 사용하여 User를 생성 또는 업데이트합니다.
    func createOrUpdateUser(with providerId: String, name: String) {
        // User 엔티티에서 uid가 providerId와 일치하는 사용자 검색 (uid 타입은 String이어야 함)
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uid == %@", providerId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingUser = results.first {
                // 기존 사용자 업데이트
                existingUser.name = name
                print("기존 사용자 업데이트: \(providerId)")
            } else {
                // 새 사용자 생성
                let newUser = User(context: context)
                newUser.uid = providerId   // providerId를 그대로 uid에 저장
                newUser.name = name
                // contents, setting 등은 기본값으로 초기화 (필요에 따라 추가)
                print("새로운 사용자 생성: \(providerId)")
            }
            try context.save()
        } catch {
            print("User 생성/업데이트 실패: \(error)")
        }
    }
}
