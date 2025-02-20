//
//  FolderModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FolderModel: Identifiable, Hashable {
    let id = UUID()
    var name: String            // 폴더명 (예: "Documents")
    var path: String            // 경로 (예: "/Documents")
    var files: [FileModel]      // 이 폴더에 속한 파일들 (필요에 따라 하위 폴더도 추가 가능)
    var createdDate: Date       // 폴더 생성일
    var modifiedDate: Date      // 폴더 수정일
    var accessedDate: Date      // 폴더 접근일 (최근에 열림)
}
