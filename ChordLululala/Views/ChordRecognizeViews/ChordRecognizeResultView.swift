//
//  ChordRecognizeResultView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

import SwiftUI

private struct PageOffset: Equatable {
    let index: Int
    let minY: CGFloat
}

private struct PageOffsetKey: PreferenceKey {
    static var defaultValue: [PageOffset] = []
    static func reduce(value: inout [PageOffset], nextValue: () -> [PageOffset]) {
        value.append(contentsOf: nextValue())
    }
}

struct ChordRecognizeResultView: View {
    @EnvironmentObject var viewModel: ChordRecognizeViewModel
    @State private var isProgrammaticScroll = false
    @State private var orientationToggle = false
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { outerGeo in
                HStack(spacing: 0) {
                    // ─ 썸네일 바 ─────────────────────────────
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(viewModel.pagesImages.indices, id: \.self) { idx in
                                VStack(spacing: 3) {
                                    Image(uiImage: viewModel.pagesImages[idx])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 94)
                                        .padding(6) // 외곽 테두리 공간 확보
                                        .background(Color.primaryBaseWhite) // 이미지 외부 배경
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(
                                                    viewModel.selectedPage == idx ? Color.primaryGray200 : Color.clear,
                                                    lineWidth: 6
                                                )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 2)) // 이미지 자체는 직각
                                        .onTapGesture {
                                            viewModel.selectedPage = idx
                                        }
                                    
                                    Text("\(idx + 1)")
                                        .textStyle(.bodyTextLgMedium)
                                        .foregroundColor(Color.primaryGray600)
                                        .frame(width: 18, height: 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(viewModel.selectedPage == idx
                                                      ? Color.primaryGray200
                                                      : Color.clear)
                                            
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 69)
                        .padding(.horizontal, 40)
                    }
                    .frame(width: 163)
                    .background(Color.primaryGray100)
                    
                    Divider()
                    
                    // ─ 메인 스크롤 뷰 ──────────────────────────
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(spacing: 24) {
                                ForEach(viewModel.pagesImages.indices, id: \.self) { idx in
                                    let img = viewModel.pagesImages[idx]
                                    
                                    ZStack {
                                        GeometryReader { geo in
                                            ZStack {
                                                // 악보 이미지
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                                    .shadow(color: Color.primaryBaseBlack.opacity(0.1), radius: 20, x: 0, y: 0)
                                                if [.chordFixing, .keyTranspostion].contains(viewModel.state) {
                                                    // 코드 박스
                                                    Group {
                                                        ForEach(viewModel.chordLists[idx], id: \.s_cid) { chord in
                                                            ChordBoxView(
                                                                chord: chord,
                                                                originalSize: img.size,
                                                                displaySize: geo.size,
                                                                transposedText: viewModel.transposedChord(for: chord.chord),
                                                                onDelete: {
                                                                    viewModel.deleteChord(chord, pageIndex: idx)
                                                                },
                                                                onMove: { newPos in
                                                                    viewModel.updateChordPosition(chord, pageIndex: idx, newPos: newPos, imageSize: img.size, displaySize: geo.size)
                                                                }
                                                            )
                                                            .onTapGesture {
                                                                viewModel.editingChord = chord
                                                            }
                                                        }
                                                    }
                                                    .id(orientationToggle)
                                                }
                                            }
                                        }
                                        .frame(
                                            width: outerGeo.size.height * img.size.width / img.size.height,
                                            height: outerGeo.size.height
                                        )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center) // 중앙 정렬
                                    .id(idx)
                                    .background(
                                        GeometryReader { geo2 in
                                            Color.clear.preference(
                                                key: PageOffsetKey.self,
                                                value: [PageOffset(index: idx, minY: geo2.frame(in: .named("scroll")).minY)]
                                            )
                                        }
                                    )
                                }
                            }
                            .padding(21)
                        }
                        .coordinateSpace(name: "scroll")
                        // 탭 → 스크롤
                        .onChange(of: viewModel.selectedPage) { page in
                            isProgrammaticScroll = true
                            proxy.scrollTo(page, anchor: .top)
                            DispatchQueue.main.async {
                                isProgrammaticScroll = false
                            }
                        }
                        // 스크롤 시 썸네일 하이라이트
                        .onPreferenceChange(PageOffsetKey.self) { offsets in
                            guard !isProgrammaticScroll else { return }
                            if let nearest = offsets.min(by: { abs($0.minY) < abs($1.minY) }),
                               nearest.index != viewModel.selectedPage {
                                viewModel.selectedPage = nearest.index
                            }
                        }
                        // 회전 감지 → orientationToggle 토글
                        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                            orientationToggle.toggle()
                        }
                    }
                }
            }
            
            if [.chordFixing, .keyTranspostion].contains(viewModel.state) {
                HStack(spacing: 6) {
                    Spacer()
                    Image("warning_code")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                    Text("인식된 코드가 잘못됐을 경우, 코드 박스를 클릭하여 수정해주세요.")
                        .textStyle(.bodyTextXLSemiBold)
                        .foregroundStyle(Color.primaryGray100)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 31)
                .background(Color.primaryGray700.opacity(0.6))
            }
        }
    }
}
