//
//  ScorePageView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/8/25.
//

import SwiftUI

struct ScorePageUnitView: View {
    let uiImage: UIImage
    let pageIndex: Int
    @ObservedObject var playmodeViewModel: PlayModeViewModel
    @ObservedObject var annotationVM: ScoreAnnotationViewModel
    @ObservedObject var chordBoxViewModel: ChordBoxViewModel
    @EnvironmentObject var settingVM: ScoreSettingViewModel
    @EnvironmentObject var zoomVM: ImageZoomViewModel
    @EnvironmentObject var pdfViewModel: ScorePDFViewModel
    @ObservedObject var pageNavViewModel: PageNavigationViewModel

    var body: some View {
        ZStack {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(zoomVM.scale)
                .offset(zoomVM.offset)
                .frame(
                    width: UIScreen.main.bounds.width *
                    CGFloat(
                        settingVM.isSinglePage
                        ? (playmodeViewModel.isOn ? 1.0 : 0.9)
                        : (playmodeViewModel.isOn ? 0.5 : 0.45)
                    )
                )
                .shadow(radius: 4)
                .padding(.vertical)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged(zoomVM.onPinchChanged)
                            .onEnded(zoomVM.onPinchEnded),
                        DragGesture()
                            .onChanged(zoomVM.onDragChanged)
                            .onEnded(zoomVM.onDragEnded)
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut) {
                        zoomVM.reset()
                    }
                }

            GeometryReader { geo in
                ForEach(chordBoxViewModel.chordsForPages[pageIndex], id: \.s_cid) { chord in
                    ChordBoxView(
                        chord: chord,
                        originalSize: uiImage.size,
                        displaySize: geo.size,
                        transposedText: chordBoxViewModel.transposedChord(for: chord.chord),
                        onDelete: nil,
                        onMove: nil
                    )
                }
            }

            if annotationVM.isEditing {
                CanvasView(
                    drawing: $annotationVM.currentDrawing,
                    isEditable: true,
                    showToolbar: true
                )
                .frame(width: UIScreen.main.bounds.width *
                        CGFloat(settingVM.isSinglePage ? (playmodeViewModel.isOn ? 1.0 : 0.9) : (playmodeViewModel.isOn ? 0.5 : 0.45)))
                .scaleEffect(zoomVM.scale)
                .offset(zoomVM.offset)
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            let threshold: CGFloat = 50
                            if gesture.translation.width > threshold {
                                if pageNavViewModel.currentPage > 0 {
                                    pageNavViewModel.currentPage -= 1
                                }
                            } else if gesture.translation.width < -threshold {
                                if pageNavViewModel.currentPage < pdfViewModel.images.count - 1 {
                                    pageNavViewModel.currentPage += 1
                                }
                            }
                        }
                )
            } else {
                CanvasView(
                    drawing: Binding(
                        get: { annotationVM.currentDrawing },
                        set: { _ in }
                    ),
                    isEditable: false,
                    showToolbar: false
                )
                .frame(width: UIScreen.main.bounds.width *
                        CGFloat(settingVM.isSinglePage ? (playmodeViewModel.isOn ? 1.0 : 0.9) : (playmodeViewModel.isOn ? 0.5 : 0.45)))
                .scaleEffect(zoomVM.scale)
                .offset(zoomVM.offset)
            }
        }
    }
}
