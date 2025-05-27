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
    @EnvironmentObject var router: NavigationRouter
    @State private var thumbnail: UIImage? = nil
    
    let file: ContentModel
    private var isSelected: Bool {
        viewModel.selectedContents.contains { $0.cid == file.cid }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // 선택 모드 오버레이: 체크 아이콘
            if viewModel.isSelectionViewVisible {
                Image(isSelected ? "selected" : "not_selected")
                    .resizable()
                    .frame(width: 25.41, height: 25.41)
                    .padding(.bottom, 6)
            }
            // 이미지 영역
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: viewModel.isLandscape ? 200 : 171, height: 114)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: viewModel.isLandscape ? 200 : 171, height: 114)
                            .overlay(
                                Text("preview")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.primaryGray400)
                            )
                    }
                }
                Button(action: {
                    viewModel.toggleContentStared(file)
                }) {
                    Image(file.isStared ? "star_fill" : "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.bottom, 3)
                        .padding(.leading, 3)
                }
                .disabled(viewModel.isSelectionViewVisible)
            }
            .frame(width: viewModel.isLandscape ? 200 : 171, height: 114)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.14), radius: 4, x: 0, y: 0)
            
            // 텍스트 + 버튼 영역
            VStack (spacing: 3){
                Text(file.name)
                    .textStyle(.bodyTextXLSemiBold)
                    .foregroundStyle(Color.primaryGray800)
                Text(file.modifiedAt.dateFormatForGrid())
                    .textStyle(.bodyTextLgRegular)
                    .foregroundStyle(Color.primaryGray600)
                if viewModel.isSearching {
                    Text(viewModel.getParentName(of: file))
                            .textStyle(.bodyTextLgRegular)
                            .foregroundStyle(Color.primaryBlue600)
                            .padding(.top, 3)
                } else {
                    Spacer()
                }
            }
            .frame(width: viewModel.isLandscape ? 200 : 171, height: 61)
        }
        .onAppear {
            loadThumbnail()
        }
        .onTapGesture {
            if viewModel.isSelectionViewVisible {
                toggleSelection()
            } else {
                // 나중에 송리스트에서도 동일한 방식 사용하기 위해 배열로 전달
                router.toNamed("/score", arguments: [file])
            }
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
            viewModel.selectedContents.removeAll { $0.cid == file.cid }
        } else {
            viewModel.selectedContents.append(file)
        }
    }
}
