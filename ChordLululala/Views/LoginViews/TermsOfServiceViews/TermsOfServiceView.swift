//
//  TermsOfServiceView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/22/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel = TermsOfServiceViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Noteflow")
                .font(.system(size: 37.06))
                .fontWeight(.bold)
                .foregroundStyle(Color.primaryBlue600)
            Text("안녕하세요.")
                .textStyle(.displayXLSemiBold)
                .foregroundStyle(Color.primaryGray900)
                .padding(.top, 13)
            Text("노트플로우 가입 및 이용을 위해 서비스 이용약관에 동의해주세요")
                .textStyle(.headingLgMedium)
                .foregroundStyle(Color.primaryGray600)
                .padding(.top, 10)
            
            AgreeButton(isAgreed: Binding(
                get: { viewModel.isAllAgreed },
                set: { newValue in
                    viewModel.isAllAgreed = newValue
                }
            )) {
                Text("전체 동의")
                    .textStyle(.headingLgSemiBold)
                    .foregroundStyle(Color.primaryGray700)
            }
            .padding(.top, 62)
            
            Divider()
                .frame(width: 235)
                .padding(.top, 15)
                .foregroundStyle(Color.primaryGray200)
            
            // 개별 동의 버튼들
            AgreeButton(isAgreed: $viewModel.isPrivacyAgreed) {
                Link("(필수) 개인정보 수집 및 이용동의", destination: URL(string: "https://example.com/privacy")!)
                    .textStyle(.headingLgMedium)
                    .foregroundColor(Color.primaryGray700)
                    .underline()
            }
            .padding(.top, 15)

            AgreeButton(isAgreed: $viewModel.isServiceAgreed) {
                Link("(필수) 서비스 이용약관", destination: URL(string: "https://example.com/terms")!)
                    .textStyle(.headingLgMedium)
                    .foregroundColor(Color.primaryGray700)
                    .underline()
            }
            .padding(.top, 12)
            
            Button(action: {
                router.offAll("/")
            }) {
                Text("홈으로")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isAllAgreed ? Color.primaryBlue600 : Color.primaryGray300)
                    .foregroundColor(Color.primaryBaseWhite)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isAllAgreed)
            .padding(.top, 20)
        }
        .padding(.horizontal, 205)
        .padding(.bottom, 258 - 203)
        .navigationBarHidden(true)
    }
}
