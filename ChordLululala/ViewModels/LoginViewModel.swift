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
    
    var appleSignInCompletion: (() -> Void)?
    func customLoginWithApple(onSuccess: @escaping () -> Void) {
        self.appleSignInCompletion = onSuccess
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
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

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let providerId = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.givenName ?? "User"
            print("커스텀 Apple 로그인 성공: \(providerId), \(fullName)")
            
            UserManager.shared.createOrUpdateUser(with: providerId, name: fullName)
            
            UserDefaults.standard.set(providerId, forKey: "lastLoggedInUserID")
            UserDefaults.standard.set(fullName, forKey: "lastLoggedInUserName")
            
            DispatchQueue.main.async {
                self.appleSignInCompletion?()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("커스텀 Apple 로그인 실패: \(error.localizedDescription)")
    }
}

extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
