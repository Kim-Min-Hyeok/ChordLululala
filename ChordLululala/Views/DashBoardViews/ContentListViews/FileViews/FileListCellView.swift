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
    
    let file: Content
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.objectID == file.objectID }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            if viewModel.isSelectionViewVisible {
                HStack {
                    Image(isSelected ? "selected" : "not_selected")
                        .resizable()
                        .frame(width: 25.41, height: 25.41)
                        .padding(.bottom, 1.59)
                }
                .frame(maxHeight: .infinity)
            }
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
            .shadow(color: Color.black.opacity(0.14), radius: 4, x: 0, y: 0)
            
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(file.name ?? "Untitled")
                            .textStyle(.bodyTextXLSemiBold)
                            .foregroundStyle(Color.primaryGray800)
                        Text(file.modifiedAt?.dateFormatForList() ?? "")
                            .textStyle(.bodyTextLgRegular)
                            .foregroundStyle(Color.primaryGray600)
                            .padding(.top, 3)
                    }
                    .padding(.top, 8)
                    Spacer()
                    Button(action: {
                        viewModel.toggleContentStared(file)
                    }) {
                        Image(file.isStared ? "star_fill" : "star")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    .padding(.top, 11)
                    .disabled(viewModel.isSelectionViewVisible)
                }
                Divider()
                    .frame(height: 1)
                    .background(Color.primaryGray200)
            }
        }
        .frame(height: 61)
        .padding(.bottom, 11)
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
        .conditionalContextMenu(isEnabled: !viewModel.isSelectionViewVisible) {
            if viewModel.dashboardContents == .trashCan {
                DeleteModalView(content: file)
            } else {
                FileContextMenuView(content: file)
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
            viewModel.selectedContents.removeAll { $0.objectID == file.objectID }
        } else {
            viewModel.selectedContents.append(file)
        }
    }
}
