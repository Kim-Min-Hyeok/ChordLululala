//
//  SingleImageView.swift
//  ChordLululala
//
//  Created by 김민준 on 5/30/25.
//

import SwiftUI


struct SingleImageView: View {
    @EnvironmentObject var zoomVM : ImageZoomViewModel
    @EnvironmentObject var settingVM: ScoreSettingViewModel

    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .scaleEffect(zoomVM.scale)
            .offset(zoomVM.offset)
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
    }
}
