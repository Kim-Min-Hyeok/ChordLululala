//
//  MyPageView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/29/25.
//  Updated by GiYoung Kim on 4/6/25.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
        VStack(spacing : 0) {
            Spacer().frame(height: 95)
            
            // 프로필 이미지
            Image(systemName: "person.crop.circle.fill") // 임시 시스템 이미지
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 76, height: 76)
                .clipShape(Circle())
                .foregroundColor(.gray)
                .padding(.bottom, 15)
            
            // 이름 + 이메일
            VStack(spacing : 0) {
                Text("김영채")
                    .textStyle(.headingXLSemiBold)
                    .foregroundColor(Color.primaryGray900)
                    .frame(height : 25.2)
                Text(verbatim: "kycskekfk@handong.ac.kr")
                    .textStyle(.headingMdMedium)
                    .foregroundColor(Color.primaryGray500)
                    .frame(height : 22.4)
            }.padding(.bottom, 57)
            
            VStack(spacing : 20){
                // 백업하기 / 불러오기 버튼
                HStack(spacing: 20) {
                    Button(action: {}) {
                        HStack(spacing : 8) {
                            Image("backup_button")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 28, height: 28)
                            Text("백업하기")
                                .textStyle(.headingMdSemiBold)
                                .foregroundColor(Color.primaryGray800)
                        }
                        .frame(maxWidth: .infinity, minHeight: 54) // 여기서 높이 지정!
                        .background(Color.primaryBaseWhite)
                        .cornerRadius(200)
                        .overlay {
                            RoundedRectangle(cornerRadius: 200)
                                .stroke(Color.primaryGray200, lineWidth: 1)
                        }
                    }
                    .frame(width: 361) // height는 안 줘도 내부에서 고정됨
                    
                    Button(action: {}) {
                        HStack(spacing : 8) {
                            Image("load_button")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 28, height: 28)
                            Text("불러오기")
                                .textStyle(.headingMdSemiBold)
                                .foregroundColor(Color.primaryGray800)
                        }
                        .frame(maxWidth: .infinity, minHeight: 54) // 여기서 높이 지정!
                        .background(Color.primaryBaseWhite)
                        .cornerRadius(200)
                        .overlay {
                            RoundedRectangle(cornerRadius: 200)
                                .stroke(Color.primaryGray200, lineWidth: 1)
                        }
                    }
                    .frame(width: 361) // height는 안 줘도 내부에서 고정됨
                }.padding(.horizontal, 46)
                
                // 목록: 휴지통
                Button(action: {}){
//                    HStack(spacing : 0){
//                        
//                    }
                    Image("trashcan_button")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                        .padding(.leading, 24)
                        .padding(.vertical, 13)
                    Text("휴지통")
                        .textStyle(.headingMdSemiBold)
                        .foregroundStyle(Color.primaryGray900)
//                        .padding(.leading, 8)
                    Spacer()
                    Text("3개")
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .background(Color.primaryBaseWhite)
                .padding(.horizontal, 46)
                .cornerRadius(5)
                
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.gray)
                    Text("언어 설정")
                        .font(.custom("Pretendard-Regular", size: 16))
                    Spacer()
                    Text("한국어")
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
            }
            
            
            Spacer()
            
            // 로그아웃 / 회원탈퇴 버튼
            HStack(spacing: 16) {
                Button("로그아웃") {}
                    .font(.custom("Pretendard-Regular", size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(6)
                
                Button("회원탈퇴") {}
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(6)
            }
            
            // 약관 링크
            VStack(spacing: 4) {
                Text("개인정보 처리방침")
                    .underline()
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(.gray)
                Text("서비스 이용약관")
                    .underline()
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer().frame(height: 16)
            
            // 탭바 자리
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "text.justify")
                    Text("악보").font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text("셋리스트").font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "person.crop.circle")
                    Text("내 계정").font(.caption)
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .shadow(color: .gray.opacity(0.1), radius: 2, y: -2)
        }
        .background(Color.primaryGray50)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MyPageView()
}
