//
import SwiftUI
import PencilKit

struct ScoreMainBodyView: View {
    @EnvironmentObject var viewModel: ScoreViewModel
    @ObservedObject var zoomViewModel: ImageZoomViewModel
    @ObservedObject var chordBoxViewModel: ChordBoxViewModel
    @ObservedObject var annotationViewModel: ScoreAnnotationViewModel
    
    @State private var toolPicker = PKToolPicker()
    
    private var pages: [UIImage] { viewModel.flatPages }
    private var rotations: [Int] { viewModel.flatRotations }
    
    private var groupedPages: [[UIImage]] {
        if viewModel.isSinglePageMode {
            return pages.map { [$0] }
        } else {
            return stride(from: 0, to: pages.count, by: 2).map { start in
                Array(pages[start..<min(start + 2, pages.count)])
            }
        }
    }
    
    private var groupSelection: Binding<Int> {
        Binding(
            get: {
                viewModel.isSinglePageMode
                ? viewModel.selectedPageIndex
                : viewModel.selectedPageIndex / 2
            },
            set: { newValue in
                viewModel.selectedPageIndex = viewModel.isSinglePageMode
                ? newValue
                : newValue * 2
            }
        )
    }
    
    var body: some View {
        ZStack {
            Color.primaryGray50.ignoresSafeArea()
            
            TabView(selection: groupSelection) {
                ForEach(Array(groupedPages.enumerated()), id: \.offset) { groupIdx, imgsInGroup in
                    HStack(spacing: 12) {
                        ForEach(Array(imgsInGroup.enumerated()), id: \.offset) { localIdx, uiImage in
                            let realIndex = viewModel.isSinglePageMode
                            ? groupIdx
                            : groupIdx * 2 + localIdx
                            
                            ZStack {
                                GeometryReader { geo in
                                    let realIndex = viewModel.isSinglePageMode
                                        ? groupIdx
                                        : (groupIdx * 2 + localIdx)
                                    let rot = rotations[realIndex]
                                    let angle = Angle(degrees: Double(rot) * 90)
                                    
                                    let imageAspect = uiImage.size.width / uiImage.size.height
                                    let containerAspect = geo.size.width / geo.size.height
                                    let displaySize: CGSize = {
                                        if imageAspect > containerAspect {
                                            let width = geo.size.width
                                            return CGSize(width: width, height: width / imageAspect)
                                        } else {
                                            let height = geo.size.height - 31
                                            return CGSize(width: height * imageAspect, height: height)
                                        }
                                    }()
                                    
                                    VStack(spacing: 0) {
                                        Spacer().frame(height: 21)
                                        ZStack {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: displaySize.width, height: displaySize.height)
                                                .shadow(radius: 4)
                                                .gesture(
                                                    MagnificationGesture()
                                                        .onChanged(zoomViewModel.onPinchChanged)
                                                        .onEnded(zoomViewModel.onPinchEnded)
                                                )
                                            // 2) 드래그 제스처: scale != 1 인 경우에만 처리
                                                .simultaneousGesture(
                                                    DragGesture()
                                                        .onChanged { value in
                                                            guard zoomViewModel.scale != 1 else { return }
                                                            zoomViewModel.onDragChanged(value)
                                                        }
                                                        .onEnded { value in
                                                            guard zoomViewModel.scale != 1 else { return }
                                                            zoomViewModel.onDragEnded(value)
                                                        }
                                                )
                                                .onTapGesture(count: 2) {
                                                    withAnimation { zoomViewModel.reset() }
                                                }
                                            
                                            if chordBoxViewModel.chordsForPages.indices.contains(realIndex) {
                                                ForEach(chordBoxViewModel.chordsForPages[realIndex], id: \.objectID) { chord in
                                                    ChordBoxView(
                                                        chord: chord,
                                                        originalSize: uiImage.size,
                                                        displaySize: displaySize,
                                                        transposedText: chordBoxViewModel.transposedChord(
                                                            for: chord.chord ?? "C",
                                                            atPage: realIndex
                                                        ),
                                                        onDelete: nil,
                                                        onMove: nil
                                                    )
                                                }
                                            }
                                            
                                            CanvasView(
                                                drawing: Binding(
                                                    get: {
                                                        annotationViewModel.pageDrawings.indices.contains(realIndex)
                                                        ? annotationViewModel.pageDrawings[realIndex]
                                                        : PKDrawing()
                                                    },
                                                    set: { newDrawing in
                                                        annotationViewModel.updateDrawing(newDrawing, forPage: realIndex)
                                                    }
                                                ),
                                                isAnnotationMode: viewModel.isAnnotationMode,
                                                sharedToolPicker: toolPicker,
                                                originalSize: uiImage.size,
                                                displaySize: displaySize
                                            )
                                            .frame(width: displaySize.width, height: displaySize.height)
                                            .allowsHitTesting(viewModel.isAnnotationMode)
                                        }
                                        .frame(width: displaySize.width, height: displaySize.height)
                                        
                                        .scaleEffect(zoomViewModel.scale)
                                        .offset(zoomViewModel.offset)
                                        Spacer().frame(height: 10)
                                    }
                                    .rotationEffect(angle)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                                }
                            }
                        }
                    }
                    .tag(groupIdx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            .overlay(
                PageIndicatorView(
                    current: viewModel.isSinglePageMode ? viewModel.selectedPageIndex + 1 : viewModel.selectedPageIndex + 2,
                    total: pages.count
                )
                .offset(x: 22, y: -10),
                alignment: .bottomLeading
            )
            
            .overlay(
                Button {
                    withAnimation {
                        zoomViewModel.reset()
                        viewModel.isPlayMode.toggle()
                    }
                } label: {
                    if viewModel.isPlayMode {
                        HStack(spacing: 3) {
                            Image("playmode_lock")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("OFF")
                                .textStyle(.headingLgMedium)
                        }
                        .frame(width: 79, height: 37)
                        .background(Color.primaryGray900)
                        .cornerRadius(32)
                        .foregroundColor(.primaryGray50)
                        .opacity(0.9)
                        
                    } else {
                        Text("연주 모드 ON")
                            .textStyle(.headingLgMedium)
                            .frame(width: 131, height: 44)
                            .background(Color.primaryGray800)
                            .cornerRadius(8)
                            .foregroundColor(.primaryGray50)
                            .opacity(0.9)
                    }
                }
                    .offset(x: viewModel.isPlayMode ?  -25 : -22, y: viewModel.isPlayMode ? -14 : -9),
                alignment: .bottomTrailing
            )
            
            if viewModel.isPlayMode {
                PlayModeOverlayView(
                    goToFirstPage: viewModel.goToFirstPage,
                    goToLastPage: viewModel.goToLastPage,
                    goToPreviousPage: viewModel.goToPreviousPage,
                    goToNextPage: viewModel.goToNextPage
                )
            }
        }
    }
}
