//
//  UserManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/22/25.
//

import Foundation

final class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var currentUser: UserModel? = nil

    private init() {
        loadUser()
    }

    func saveUser(
        id: String? = nil,
        providerId: String?,
        name: String?,
        email: String?,
        profileImageURL: String?
    ) {
        // 이전 값
        let prevId = UserDefaults.standard.string(forKey: "lastLoggedInUserUUID")
        let prevProviderId = UserDefaults.standard.string(forKey: "lastLoggedInUserID")
        let prevName = UserDefaults.standard.string(forKey: "lastLoggedInUserName")
        let prevEmail = UserDefaults.standard.string(forKey: "lastLoggedInUserEmail")
        let prevProfile = UserDefaults.standard.string(forKey: "lastLoggedInUserProfileImageURL")

        // id: 값 있으면 덮어쓰기, 없으면 기존 유지, 둘 다 없으면 생성
        var finalId = id ?? prevId
        if finalId == nil {
            finalId = UUID().uuidString
        }

        let finalProviderId = providerId ?? prevProviderId
        let finalName: String?
        if let n = name, n != "User" { finalName = n }
        else { finalName = prevName }
        let finalEmail = email ?? prevEmail
        let finalProfile = profileImageURL ?? prevProfile

        // 저장
        UserDefaults.standard.set(finalId, forKey: "lastLoggedInUserUUID")
        UserDefaults.standard.set(finalProviderId, forKey: "lastLoggedInUserID")
        UserDefaults.standard.set(finalName, forKey: "lastLoggedInUserName")
        UserDefaults.standard.set(finalEmail, forKey: "lastLoggedInUserEmail")
        UserDefaults.standard.set(finalProfile, forKey: "lastLoggedInUserProfileImageURL")

        currentUser = UserModel(
            id: finalId!,
            providerId: finalProviderId,
            name: finalName,
            email: finalEmail,
            profileImageURL: finalProfile
        )
    }

    func loadUser() {
        guard let id = UserDefaults.standard.string(forKey: "lastLoggedInUserUUID") else {
            currentUser = nil
            return
        }
        currentUser = UserModel(
            id: id,
            providerId: UserDefaults.standard.string(forKey: "lastLoggedInUserID"),
            name: UserDefaults.standard.string(forKey: "lastLoggedInUserName"),
            email: UserDefaults.standard.string(forKey: "lastLoggedInUserEmail"),
            profileImageURL: UserDefaults.standard.string(forKey: "lastLoggedInUserProfileImageURL")
        )
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUserUUID")
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUserID")
        currentUser = nil
    }

    func printCurrentUserDefaults() {
        let id = UserDefaults.standard.string(forKey: "lastLoggedInUserUUID")
        let providerId = UserDefaults.standard.string(forKey: "lastLoggedInUserID")
        let name = UserDefaults.standard.string(forKey: "lastLoggedInUserName")
        let email = UserDefaults.standard.string(forKey: "lastLoggedInUserEmail")
        let profile = UserDefaults.standard.string(forKey: "lastLoggedInUserProfileImageURL")

        print("""
        ===== UserDefaults 유저 정보 =====
        id: \(id ?? "nil")
        providerId: \(providerId ?? "nil")
        name: \(name ?? "nil")
        email: \(email ?? "nil")
        profileImageURL: \(profile ?? "nil")
        ===============================
        """)
    }
}
