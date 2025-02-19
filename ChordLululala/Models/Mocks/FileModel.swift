//
//  FileModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/19/25.
//

import SwiftUI

struct FileModel: Identifiable, Hashable {
    let id = UUID()
    var name: String            // 예: "Document1.pdf"
    var location: String        // 예: "/Documents" (또는 전체 경로)
    var imageName: String       // SFSymbol 이름, 예: "doc.richtext"
    var isTrash: Bool           // 휴지통 여부
    var createdDate: Date       // 파일 생성일
    var modifiedDate: Date      // 파일 수정일
    var accessedDate: Date      // 파일 접근일 (최근에 열림)
    
    // SFSymbol 이미지를 제공하는 계산 프로퍼티
    var image: Image {
        Image(systemName: imageName)
    }
}
