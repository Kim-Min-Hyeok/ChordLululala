//
//  ProfileView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/14/25.
//

import SwiftUI

struct ProfileView: View {
    let name: String?
    let email: String?
    let profileImageURL: String?

    var body: some View {
        VStack(spacing: 0) {
            // 프로필 이미지
            if let profileImageURL = profileImageURL,
               let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 76, height: 76)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                    case .failure(_):
                        defaultProfileImage
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 15)
            } else {
                defaultProfileImage
                    .padding(.bottom, 15)
            }

            // 이름 + 이메일
            VStack(spacing: 0) {
                Text(name ?? "이름 없음")
                    .textStyle(.headingXLSemiBold)
                    .foregroundColor(Color.primaryGray900)
                    .frame(height: 25.2)

                Text(verbatim: email ?? "이메일 없음")
                    .textStyle(.headingMdMedium)
                    .foregroundColor(Color.primaryGray500)
                    .frame(height: 22.4)
            }
            .padding(.bottom, 24)
        }
    }

    private var defaultProfileImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 76, height: 76)
            .clipShape(Circle())
            .foregroundColor(.gray)
    }
}
