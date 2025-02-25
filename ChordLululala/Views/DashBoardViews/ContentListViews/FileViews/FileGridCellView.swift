//
//  FileGridCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI
import QuickLookThumbnailing

struct FileGridCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @State private var thumbnail: UIImage? = nil
    
    let file: ContentModel
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == file.cid }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 이미지 영역
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 114)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 114)
                            .overlay(Text("Loading").font(.caption))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionViewVisible {
                        toggleSelection()
                    } else {
                        // 일반 파일 탭 액션 구현
                    }
                }
                
                // 텍스트 + 버튼 영역
                HStack {
                    Text(file.name)
                        .font(.caption)
                        .foregroundColor(.black)
                    Spacer()
                    if !viewModel.isSelectionViewVisible {
                        Button(action: {
                            viewModel.selectedContent = file
                            if viewModel.dashboardContents == .trashCan {
                                viewModel.isDeletedModalVisible = true
                            }
                            else {
                                viewModel.isModifyModalVisible = true
                            }
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 44, height: 44)
                    }
                }
                .frame(height: 32)
                .background(Color.blue)
            }
            .frame(height: 114 + 32)
            .background(Color.red) // 테스트용 배경색
            .cornerRadius(9)
            .onAppear {
                loadThumbnail()
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.cellFrame = geo.frame(in: .global)
                    }
                }
            )
            
            // 선택 모드 오버레이: 체크 아이콘
            if viewModel.isSelectionViewVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 9)
                    }
                    .padding(.bottom, 10)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection()
                }
            }
        }
    }
    
    private func loadThumbnail() {
        guard let relativePath = file.path, !relativePath.isEmpty,
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("파일 경로 없음")
            return
        }
        let fileURL = docsURL.appendingPathComponent(relativePath)
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: CGSize(width: 201, height: 114),
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnailRep, error in
            if let thumbnailRep = thumbnailRep {
                DispatchQueue.main.async {
                    self.thumbnail = thumbnailRep.uiImage
                }
            } else {
                print("썸네일 생성 실패: \(String(describing: error))")
            }
        }
    }
    
    private func toggleSelection() {
        if isSelected {
            viewModel.selectedContents.removeAll { $0.cid == file.cid }
        } else {
            viewModel.selectedContents.append(file)
        }
    }
}
