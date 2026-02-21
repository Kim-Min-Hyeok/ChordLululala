//
//  UploadProgressModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/26.
//

import SwiftUI

struct UploadProgressModalView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("파일 추가 중")
                    .font(.headingMdSemiBold)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                Text("\(viewModel.uploadTotalCount)개 중 \(viewModel.uploadCompletedCount)개 완료")
                    .font(.bodyTextLgRegular)
                    .foregroundColor(.primaryGray500)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)

                ProgressView(value: viewModel.uploadTotalCount > 0
                    ? Double(viewModel.uploadCompletedCount) / Double(viewModel.uploadTotalCount)
                    : 0)
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
                    Button(action: {
                        viewModel.cancelUpload()
                    }) {
                        Text("추가 중단")
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
