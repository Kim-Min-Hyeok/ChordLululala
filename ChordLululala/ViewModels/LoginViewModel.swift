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

    override init() {
        super.init()
        self.user = UserManager.shared.currentUser
        UserManager.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$user)
    }
    
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
        Future<(String, String, String?, String?), Error> { promise in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    let providerId = result.user.userID ?? "Unknown"
                    let fullName = result.user.profile?.name ?? "User"
                    let email = result.user.profile?.email
                    let profileImageURL = result.user.profile?.imageURL(withDimension: 100)?.absoluteString
                    promise(.success((providerId, fullName, email, profileImageURL)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("구글 로그인 실패: \(error.localizedDescription)")
            }
        } receiveValue: { providerId, fullName, email, profileImageURL in
            print("구글 로그인 성공: \(providerId), \(fullName), \(email ?? ""), \(profileImageURL ?? "")")
            UserManager.shared.saveUser(
                providerId: providerId,
                name: fullName,
                email: email,
                profileImageURL: profileImageURL
            )
            DispatchQueue.main.async {
                onSuccess()
                UserManager.shared.printCurrentUserDefaults()
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: - Apple Delegate
extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let providerId = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.givenName ?? "User"
            let email = appleIDCredential.email // 최초 로그인시에만 값 있음
            print("커스텀 Apple 로그인 성공: \(providerId), \(fullName), \(email ?? "")")
            UserManager.shared.saveUser(
                providerId: providerId,
                name: fullName,
                email: email,
                profileImageURL: nil // 애플은 프로필 없음
            )
            DispatchQueue.main.async {
                self.appleSignInCompletion?()
                UserManager.shared.printCurrentUserDefaults()
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
