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
                .foregroundStyle(Color.primaryBlue600)
            
            Group {
                // 애플 로그인 버튼
                Button(action: {
                    viewModel.customLoginWithApple {
                        router.toNamed("/termsofservice")
                    }
                }) {
                    HStack(spacing: 4) {
                        Image("apple_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Apple로 계속하기")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primaryBaseWhite)
                    }
                    .frame(width: 346, height: 49)
                    .background(Color.primaryBaseBlack)
                    .cornerRadius(5)
                }
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
                            .foregroundStyle(Color.primaryBaseBlack)
                    }
                    .frame(width: 346, height: 49)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .background(Color.primaryBaseWhite)
                .cornerRadius(5)
                .padding(.top, 20)
            }
        }
        .padding(.bottom, 333 - 278)
        .navigationBarHidden(true)
    }
}
