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
    @EnvironmentObject var vm: ChordRecognizeViewModel
    @State private var selectedPage = 0
    @State private var isProgrammaticScroll = false
    @State private var orientationToggle = false

    var body: some View {
        GeometryReader { outerGeo in
            HStack(spacing: 0) {
                // ─ 썸네일 바 ─────────────────────────────
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vm.pagesImages.indices, id: \.self) { idx in
                            Image(uiImage: vm.pagesImages[idx])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 100)
                                .border(
                                    selectedPage == idx
                                        ? Color.primaryBlue600
                                        : Color.clear,
                                    width: 2
                                )
                                .onTapGesture {
                                    selectedPage = idx
                                }
                        }
                    }
                    .padding()
                }
                .frame(width: 100)
                .background(Color.primaryGray100)

                Divider()

                // ─ 메인 스크롤 뷰 ──────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 24) {
                            ForEach(vm.pagesImages.indices, id: \.self) { idx in
                                let img = vm.pagesImages[idx]
                                GeometryReader { geo in
                                    ZStack {
                                        // 이미지
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geo.size.width, height: geo.size.height)

                                        // 코드 박스, orientationToggle로 강제 리로드
                                        Group {
                                            ForEach(vm.chordLists[idx], id: \.s_cid) { chord in
                                                ChordBoxView(
                                                    chord: chord,
                                                    originalSize: img.size,
                                                    displaySize: geo.size
                                                )
                                            }
                                        }
                                        .id(orientationToggle)
                                    }
                                }
                                // outerGeo를 사용해 width 계산, UIScreen 대신 사용
                                .frame(
                                    width: outerGeo.size.width - 100,
                                    height: (outerGeo.size.width - 100) * img.size.height / img.size.width
                                )
                                .id(idx)
                                .background(
                                    GeometryReader { geo2 in
                                        Color.clear
                                            .preference(
                                                key: PageOffsetKey.self,
                                                value: [PageOffset(
                                                    index: idx,
                                                    minY: geo2.frame(in: .named("scroll")).minY
                                                )]
                                            )
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    .coordinateSpace(name: "scroll")
                    // 탭 → 스크롤
                    .onChange(of: selectedPage) { page in
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
                           nearest.index != selectedPage {
                            selectedPage = nearest.index
                        }
                    }
                    // 회전 감지 → orientationToggle 토글
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        orientationToggle.toggle()
                    }
                }
            }
        }
        .navigationTitle("인식 결과")
        .navigationBarTitleDisplayMode(.inline)
    }
}
