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
        VStack {
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Image("noteflow_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 47, height: 47)
                        .padding(.trailing, 12)
                    Text("Noteflow")
                        .textStyle(.loginLogo)
                        .foregroundStyle(Color.primaryBlue600)
                }
                Text("안녕하세요.")
                    .textStyle(.displayXLSemiBold)
                    .foregroundStyle(Color.primaryGray900)
                    .padding(.top, 13)
                Text("노트플로우 서비스 이용약관에 동의해주세요.")
                    .textStyle(.headingLgMedium)
                    .foregroundStyle(Color.primaryGray600)
                    .padding(.top, 10)
                
                AgreeButton(isAgreed: Binding(
                    get: { viewModel.isAllAgreed },
                    set: { newValue in
                        viewModel.isAllAgreed = newValue
                    }
                )) {
                    Text("네, 모두 동의합니다.")
                        .textStyle(.headingLgSemiBold)
                        .foregroundStyle(Color.primaryGray700)
                }
                .padding(.top, 62)
                                
                // 개별 동의 버튼들
                AgreeButton(isAgreed: $viewModel.isPrivacyAgreed) {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Text("(필수) 개인정보 수집 및 이용 동의")
                            .textStyle(.headingLgMedium)
                            .foregroundColor(Color.primaryGray700)
                            .underline()
                    }
                }
                .padding(.top, 15)

                AgreeButton(isAgreed: $viewModel.isServiceAgreed) {
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Text("(필수) 서비스 이용약관")
                            .textStyle(.headingLgMedium)
                            .foregroundColor(Color.primaryGray700)
                            .underline()
                    }
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 205)
            .padding(.top, 37)
            
            Spacer()
            
            Button(action: {
                router.offAll("/")
            }) {
                Text("동의하고 진행하기")
                    .textStyle(.displayXLSemiBold)
                    .frame(maxWidth: .infinity, maxHeight: 109.1)
                    .background(viewModel.isAllAgreed ? Color.primaryBlue700 : Color.primaryGray200)
                    .foregroundColor(viewModel.isAllAgreed ? Color.primaryBaseWhite : Color.primaryGray500)
            }
            .buttonStyle(NoPressedEffectButtonStyle())
            .disabled(!viewModel.isAllAgreed)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

/// 버튼 프레스드 효과 제거 
struct NoPressedEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label // pressed 여부에 따라 변화 없음
    }
}
