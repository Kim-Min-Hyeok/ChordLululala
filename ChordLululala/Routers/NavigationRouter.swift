//
//  NavigationRouter.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import Combine
import SwiftUI

/// Combine & NavigationStack을 활용한 라우팅 상태 관리
final class NavigationRouter: ObservableObject {
    /// NavigationStack에서 관리할 경로 배열
    @Published var path: [Route] = []
    
    /// 해당 경로로 이동 (push)
    func toNamed(_ route: String, arguments: AnyHashable? = nil) {
        let newRoute = Route(name: route, arguments: arguments)
        path.append(newRoute)
    }

    /// 뒤로가기 (pop)
    func back() {
        _ = path.popLast()
    }
    
    /// 현재 화면을 제거하고 해당 경로로 이동 (replace)
    func offNamed(_ route: String, arguments: AnyHashable? = nil) {
        if !path.isEmpty {
            _ = path.popLast()
        }
        toNamed(route, arguments: arguments)
    }
    
    /// 전체 스택을 비우고 해당 경로를 새 루트로 설정
    func offAll(_ route: String, arguments: AnyHashable? = nil) {
        path.removeAll()
        toNamed(route, arguments: arguments)
    }
}
