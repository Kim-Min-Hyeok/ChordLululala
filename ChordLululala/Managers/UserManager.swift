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
        profileImageURL: String?,
        singPageView: Bool? = true
    ) {
        // 이전 값
        let prevId = UserDefaults.standard.string(forKey: "lastLoggedInUserUUID")
        let prevProviderId = UserDefaults.standard.string(forKey: "lastLoggedInUserID")
        let prevName = UserDefaults.standard.string(forKey: "lastLoggedInUserName")
        let prevEmail = UserDefaults.standard.string(forKey: "lastLoggedInUserEmail")
        let prevProfile = UserDefaults.standard.string(forKey: "lastLoggedInUserProfileImageURL")
        let prevSingPageView = UserDefaults.standard.bool(forKey: "lastLoggedInSinglePageView")
        
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
        let finalSinglePageView = singPageView ?? prevSingPageView
        
        // 저장
        UserDefaults.standard.set(finalId, forKey: "lastLoggedInUserUUID")
        UserDefaults.standard.set(finalProviderId, forKey: "lastLoggedInUserID")
        UserDefaults.standard.set(finalName, forKey: "lastLoggedInUserName")
        UserDefaults.standard.set(finalEmail, forKey: "lastLoggedInUserEmail")
        UserDefaults.standard.set(finalProfile, forKey: "lastLoggedInUserProfileImageURL")
        UserDefaults.standard.set(finalSinglePageView, forKey: "lastLoggedInSinglePageView")
        currentUser = UserModel(
            id: finalId!,
            providerId: finalProviderId,
            name: finalName,
            email: finalEmail,
            profileImageURL: finalProfile,
            isSinglePageView: finalSinglePageView
        )
    }

    func loadUser() {
        guard let id = UserDefaults.standard.string(forKey: "lastLoggedInUserUUID") else {
            print("🚫 UserDefaults에 사용자 UUID가 없습니다.")
            currentUser = nil
            return
        }
        
            let providerId = UserDefaults.standard.string(forKey: "lastLoggedInUserID")
            let name = UserDefaults.standard.string(forKey: "lastLoggedInUserName")
            let email = UserDefaults.standard.string(forKey: "lastLoggedInUserEmail")
            let profile = UserDefaults.standard.string(forKey: "lastLoggedInUserProfileImageURL")
            let isSinglePageView = UserDefaults.standard.bool(forKey: "lastLoggedInSinglePageView")
        
            print("""
            ✅ UserManager.loadUser()
            id: \(id)
            providerId: \(providerId ?? "nil")
            name: \(name ?? "nil")
            email: \(email ?? "nil")
            profileImageURL: \(profile ?? "nil")
            """)

            currentUser = UserModel(
                id: id,
                providerId: providerId,
                name: name,
                email: email,
                profileImageURL: profile,
                isSinglePageView: isSinglePageView
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
    
    //MARK: - 악보 보기 설정 변경 
    func updatePageViewSetting(isSinglePage: Bool){
        guard currentUser != nil else {
            print(#fileID,#function,#line, "설정 변경 실패 : 로그인된 유저가 없습니다.")
            return
        }
        currentUser?.isSinglePageView = isSinglePage
        UserDefaults.standard.set(isSinglePage, forKey: "lastLoggedInSinglePageView" )
    }
    
    
}
