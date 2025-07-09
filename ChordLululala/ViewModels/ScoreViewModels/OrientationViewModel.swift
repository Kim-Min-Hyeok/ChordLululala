//
//  OrientationInfo.swift
//  ChordLululala
//
//  Created by 김민준 on 7/9/25.
//

import SwiftUI
import Combine

final class OrientationViewModel: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    private var cancellable: AnyCancellable?
    
    init(){
        self.isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                let orientation = UIDevice.current.orientation
                if orientation.isValidInterfaceOrientation {
                    self.isLandscape = orientation.isLandscape
                } else {
                    self.isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
                }
            }
    }
    
    
}
