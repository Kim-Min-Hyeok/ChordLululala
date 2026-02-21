//
//  CellFramePreferenceKey.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/26.
//

import SwiftUI
import CoreData

struct CellFramePreference: Equatable {
    let id: NSManagedObjectID
    let frame: CGRect
}

struct CellFramePreferenceKey: PreferenceKey {
    static var defaultValue: [CellFramePreference] = []

    static func reduce(value: inout [CellFramePreference], nextValue: () -> [CellFramePreference]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    func reportCellFrame(objectID: NSManagedObjectID) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CellFramePreferenceKey.self,
                    value: [CellFramePreference(
                        id: objectID,
                        frame: geo.frame(in: .named("contentListArea"))
                    )]
                )
            }
        )
    }
}
