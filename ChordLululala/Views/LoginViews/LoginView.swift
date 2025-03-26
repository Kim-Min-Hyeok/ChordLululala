//
//  LoginView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/22/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack {
            Text("Noteflow")
                .font(.system(size: 37.06))
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            
            Group {
                // 애플 로그인 버튼
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        viewModel.loginWithApple(result: result) {
                            router.toNamed("/termsofservice")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 346, height: 49)
                .cornerRadius(5)
                .padding(.top, 49)
                
                // 구글 로그인 버튼
                Button(action: {
                    viewModel.loginWithGoogle {
                        router.toNamed("/termsofservice")
                    }
                }) {
                    HStack(spacing: 4) {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Google로 계속하기")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 346, height: 49)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .background(Color.white)
                .cornerRadius(5)
                .padding(.top, 20)
            }
        }
        .padding(.bottom, 333 - 278)
        .navigationBarHidden(true)
    }
}
