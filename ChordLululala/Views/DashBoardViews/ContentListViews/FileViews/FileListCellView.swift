//
//  FileListCellView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI
import QuickLookThumbnailing

struct FileListCellView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    @EnvironmentObject var router: NavigationRouter
    @State private var thumbnail: UIImage? = nil
    
    let file: ContentModel
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == file.cid }
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 18) {
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 78, height: 57)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.primaryGray200)
                            .frame(width: 78, height: 57)
                            .overlay(
                                Text("preview")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.primaryGray400)
                            )
                    }
                }
                .cornerRadius(6)
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(file.name)
                                .textStyle(.bodyTextXLSemiBold)
                                .foregroundStyle(Color.primaryGray800)
                            Text(file.modifiedAt.dateFormatForList())
                                .textStyle(.bodyTextLgRegular)
                                .foregroundStyle(Color.primaryGray600)
                                .padding(.top, 3)
                        }
                        .padding(.top, 8)
                        Spacer()
                        if !viewModel.isSelectionViewVisible {
                            Button(action: {
                                
                            }) {
                                Image("star")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .padding(.top, 11)
                            Button(action: {
                                viewModel.selectedContent = file
                                if viewModel.dashboardContents == .trashCan {
                                    viewModel.isDeletedModalVisible = true
                                }
                                else {
                                    viewModel.isModifyModalVisible = true
                                }
                            }) {
                                Image("more")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .padding(.top, 11)
                        }
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.primaryGray200)
                }
            }
            .frame(height: 61)
            .onTapGesture {
                if viewModel.isSelectionViewVisible {
                    toggleSelection()
                } else {
                    // 나중에 송리스트에서도 동일한 방식 사용하기 위해 배열로 전달
                    router.toNamed("/score", arguments: [file])
                }
            }
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
            if viewModel.isSelectionViewVisible {
                HStack {
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 9)
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
