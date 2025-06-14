//
//  MyPageAccountModalView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/14/25.
//

import SwiftUI

struct MyPageAccountModalView: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headingMdSemiBold)
                    .padding(.top, 18)
                    .padding(.bottom, 8)
                Text(message)
                    .font(.bodyTextLgRegular)
                    .foregroundColor(.primaryGray500)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)

                HStack(spacing: 0) {
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .font(.headingLgMedium)
                            .frame(width: 154, height: 50)
                    }
                    .foregroundColor(.primaryBlue600)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.primaryGray300),
                        alignment: .top
                    )

                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.headingLgSemiBold)
                            .frame(width: 155, height: 50)
                    }
                    .foregroundColor(.supportingRed500)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.primaryGray300),
                        alignment: .top
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.primaryGray300),
                        alignment: .leading
                    )
                }
            }
            .padding(.horizontal, 24)
            .frame(width: 309)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
        }
    }
}
