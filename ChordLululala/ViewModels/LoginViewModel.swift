//
//  LoginViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/22/25.
//

import SwiftUI
import Combine
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: NSObject, ObservableObject {
    @Published var user: UserModel? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func loginWithApple(result: Result<ASAuthorization, Error>, onSuccess: @escaping () -> Void) {
        switch result {
        case .success(let authResults):
            if let appleCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                let providerId = appleCredential.user
                let fullName = appleCredential.fullName?.givenName ?? "User"
                print("Apple 로그인 성공: \(providerId), \(fullName)")
                
                UserManager.shared.createOrUpdateUser(with: providerId, name: fullName)
                
                UserDefaults.standard.set(providerId, forKey: "lastLoggedInUserID")
                UserDefaults.standard.set(fullName, forKey: "lastLoggedInUserName")
                
                DispatchQueue.main.async {
                    onSuccess()
                }
            }
        case .failure(let error):
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    func loginWithGoogle(onSuccess: @escaping () -> Void) {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("GIDClientID가 Info.plist에 없습니다.")
            return
        }
        
        _ = GIDConfiguration(clientID: clientID)
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            print("루트 뷰 컨트롤러를 찾을 수 없습니다.")
            return
        }
        
        Future<(String, String), Error> { promise in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    let providerId = result.user.userID ?? "Unknown"
                    let fullName = result.user.profile?.name ?? "User"
                    promise(.success((providerId, fullName)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("구글 로그인 실패: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] providerId, fullName in
            guard self != nil else { return }
            print("구글 로그인 성공: \(providerId), \(fullName)")
            
            UserManager.shared.createOrUpdateUser(with: providerId, name: fullName)
            
            UserDefaults.standard.set(providerId, forKey: "lastLoggedInUserID")
            UserDefaults.standard.set(fullName, forKey: "lastLoggedInUserName")
            
            DispatchQueue.main.async {
                onSuccess()
            }
        }
        .store(in: &cancellables)
    }
}
