//
//  BackupProgressModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 7/11/25.
//

import SwiftUI

struct BackupProgressModalView: View {
    @EnvironmentObject var viewModel: MyPageViewModel
    
    let onBackupCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(viewModel.backupState == .backingUp ? "내보내기 준비중" : "불러오기 준비중")
                    .font(.headingMdSemiBold)
                    .padding(.top, 18)
                    .padding(.bottom, 8)
                     
                Text(viewModel.backupState == .backingUp
                     ? "내보낼 데이터를 모으로 있습니다."
                     : "불러올 데이터를 모으고 있습니다.")
                    .font(.bodyTextLgRegular)
                    .foregroundColor(.primaryGray500)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)
                
                // 프로그래스
                ProgressView(value: viewModel.progressValue)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 9)
                    .tint(.primaryBlue600)
                    .padding(.top, 12)
                    .padding(.bottom, 21)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundColor(Color.primaryGray300)
                
                HStack(spacing: 0) {
                    Button(action: onBackupCancel) {
                        Text(viewModel.backupState == .backingUp ? "백업 중단" : "불러오기 중단")
                            .font(.headingLgMedium)
                            .frame(maxWidth: .infinity, maxHeight: 51)
                    }
                    .foregroundColor(.supportingRed500)
                }
            }
            .frame(width: 309)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
        }
    }
}
