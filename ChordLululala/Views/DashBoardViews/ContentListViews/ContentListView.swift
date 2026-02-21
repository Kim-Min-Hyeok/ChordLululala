//
//  ContentListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/22/25.
//

import SwiftUI
import CoreData

struct ContentListView: View {
    @EnvironmentObject var viewModel: DashBoardViewModel
    var isListView: Bool
    var isSelectionMode: Bool = false

    @State private var cellFrames: [NSManagedObjectID: CGRect] = [:]
    @State private var dragDirectionDecided: Bool = false
    @State private var isHorizontalDrag: Bool = false

    var body: some View {
        if viewModel.sortedContents.isEmpty {
            VStack {
                Image("empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                Text("악보가 없습니다.")
                    .textStyle(.headingMdMedium)
                    .foregroundColor(Color.primaryGray500)
                    .frame(height: 22)
                    .padding(.top, 15)
                Text("새로운 파일을 업로드하거나 폴더를 생성하세요")
                    .textStyle(.bodyTextLgMedium)
                    .foregroundColor(Color.primaryGray300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 154)
        }
        else {
            ScrollView {
                Group {
                    if isListView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.sortedContents, id: \.objectID) { content in
                                cellView(for: content)
                                    .reportCellFrame(objectID: content.objectID)
                            }
                        }
                    } else {
                        let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(viewModel.sortedContents, id: \.objectID) { content in
                                cellView(for: content)
                                    .reportCellFrame(objectID: content.objectID)
                            }
                        }
                    }
                }
                .onPreferenceChange(CellFramePreferenceKey.self) { prefs in
                    var newFrames: [NSManagedObjectID: CGRect] = [:]
                    for pref in prefs {
                        newFrames[pref.id] = pref.frame
                    }
                    cellFrames = newFrames
                }
            }
            .scrollDisabled(isHorizontalDrag)
            .coordinateSpace(name: "contentListArea")
            .simultaneousGesture(
                viewModel.isSelectionViewVisible ? dragGesture : nil
            )
        }
    }

    // MARK: - 셀 뷰 분기
    @ViewBuilder
    private func cellView(for content: Content) -> some View {
        if isListView {
            switch content.type {
            case ContentType.folder.rawValue:
                FolderListCellView(folder: content)
            case ContentType.score.rawValue:
                FileListCellView(file: content)
            case ContentType.setlist.rawValue:
                SetlistListCellView(setlist: content)
            default:
                EmptyView()
            }
        } else {
            switch content.type {
            case ContentType.folder.rawValue:
                FolderGridCellView(folder: content)
            case ContentType.score.rawValue:
                FileGridCellView(file: content)
            case ContentType.setlist.rawValue:
                SetlistGridCellView(setlist: content)
            default:
                EmptyView()
            }
        }
    }

    // MARK: - 드래그 제스처 (사진 앱 방식)
    // 수평으로 시작하면 → 범위 기반 다중 선택 (이후 수직 이동도 선택 유지)
    // 수직으로 시작하면 → 스크롤
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .named("contentListArea"))
            .onChanged { value in
                if !dragDirectionDecided {
                    dragDirectionDecided = true
                    let dx = abs(value.translation.width)
                    let dy = abs(value.translation.height)

                    if dx >= dy {
                        // 수평 시작 → 스크롤 차단, 시작 셀 기준으로 다중 선택 시작
                        isHorizontalDrag = true
                        let startID = hitTest(at: value.startLocation)
                            ?? hitTest(at: value.location)
                        if let startID = startID {
                            viewModel.startDragSelection(at: startID)
                        }
                    }
                    // 수직 시작 → 아무것도 하지 않음 (스크롤 유지)
                }

                guard viewModel.isDragSelecting else { return }

                if let hitID = hitTest(at: value.location) {
                    viewModel.updateDragSelection(with: hitID)
                }
            }
            .onEnded { _ in
                if viewModel.isDragSelecting {
                    viewModel.endDragSelection()
                }
                dragDirectionDecided = false
                isHorizontalDrag = false
            }
    }

    // MARK: - 좌표 → 셀 매칭
    private func hitTest(at point: CGPoint) -> NSManagedObjectID? {
        for (id, frame) in cellFrames {
            if frame.contains(point) {
                return id
            }
        }
        return nil
    }
}
