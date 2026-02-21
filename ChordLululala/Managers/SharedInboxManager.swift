//
//  SharedInboxManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/21/26.
//

import Foundation
import Combine
import CoreData
import UIKit

final class SharedInboxManager {
    static let shared = SharedInboxManager()
    private let appGroupID = "group.com.noteflow.chordlululala"
    private var context: NSManagedObjectContext { CoreDataManager.shared.context }

    private init() {}

    private var sharedInboxURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("SharedInbox", isDirectory: true)
    }

    func importSharedInboxFiles() -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self = self,
                  let inboxURL = self.sharedInboxURL else {
                promise(.success(false))
                return
            }

            let fileManager = FileManager.default

            // SharedInbox 폴더가 없으면 생성 후 빈 상태로 종료
            if !fileManager.fileExists(atPath: inboxURL.path) {
                try? fileManager.createDirectory(at: inboxURL, withIntermediateDirectories: true)
                promise(.success(false))
                return
            }

            guard let items = try? fileManager.contentsOfDirectory(
                at: inboxURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ), !items.isEmpty else {
                promise(.success(false))
                return
            }

            // Score 베이스 디렉토리 가져오기
            guard let scoreBase = ContentCoreDataManager.shared.fetchBaseDirectory(named: "Score"),
                  let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                promise(.success(false))
                return
            }

            let scoreDir = docsURL.appendingPathComponent("Score", isDirectory: true)
            try? fileManager.createDirectory(at: scoreDir, withIntermediateDirectories: true)

            let now = Date()
            var importedCount = 0

            for fileURL in items {
                let ext = fileURL.pathExtension.lowercased()

                if ["jpg", "jpeg", "png", "heic"].contains(ext) {
                    // 이미지 → PDF 변환 후 Score/에 저장
                    guard let image = UIImage(contentsOfFile: fileURL.path) else {
                        try? fileManager.removeItem(at: fileURL)
                        continue
                    }

                    let baseName = (fileURL.deletingPathExtension().lastPathComponent)
                    let pdfName = self.uniqueFileName(baseName + ".pdf", in: scoreDir)
                    let pdfRelPath = "Score/\(pdfName)"
                    let pdfDestURL = scoreDir.appendingPathComponent(pdfName)

                    let pdfRenderer = UIGraphicsPDFRenderer(
                        bounds: CGRect(origin: .zero, size: image.size)
                    )
                    let pdfData = pdfRenderer.pdfData { ctx in
                        ctx.beginPage()
                        image.draw(in: CGRect(origin: .zero, size: image.size))
                    }

                    do {
                        try pdfData.write(to: pdfDestURL)
                    } catch {
                        print("❌ [SharedInbox] 이미지 → PDF 변환 실패: \(error)")
                        try? fileManager.removeItem(at: fileURL)
                        continue
                    }

                    // Core Data 엔티티 생성
                    self.createScoreEntities(
                        name: pdfName,
                        path: pdfRelPath,
                        pdfURL: pdfDestURL,
                        parent: scoreBase,
                        now: now
                    )
                    importedCount += 1
                    print("🖼️→📄 [SharedInbox] \(fileURL.lastPathComponent) → \(pdfName)")

                    // SharedInbox에서 삭제
                    try? fileManager.removeItem(at: fileURL)

                } else if ext == "pdf" {
                    // PDF → Score/에 복사
                    let pdfName = self.uniqueFileName(fileURL.lastPathComponent, in: scoreDir)
                    let pdfRelPath = "Score/\(pdfName)"
                    let pdfDestURL = scoreDir.appendingPathComponent(pdfName)

                    do {
                        try fileManager.copyItem(at: fileURL, to: pdfDestURL)
                    } catch {
                        print("❌ [SharedInbox] PDF 복사 실패: \(error)")
                        try? fileManager.removeItem(at: fileURL)
                        continue
                    }

                    // Core Data 엔티티 생성
                    self.createScoreEntities(
                        name: pdfName,
                        path: pdfRelPath,
                        pdfURL: pdfDestURL,
                        parent: scoreBase,
                        now: now
                    )
                    importedCount += 1
                    print("📄 [SharedInbox] PDF 추가: \(pdfRelPath)")

                    // SharedInbox에서 삭제
                    try? fileManager.removeItem(at: fileURL)

                } else {
                    // 지원하지 않는 파일 형식은 삭제
                    try? fileManager.removeItem(at: fileURL)
                }
            }

            if importedCount > 0 {
                do {
                    try self.context.save()
                    print("✅ [SharedInbox] context.save() 완료 (\(importedCount)개 파일)")
                } catch {
                    print("❌ [SharedInbox] CoreData 저장 오류: \(error)")
                }
            }

            promise(.success(importedCount > 0))
        }
        .eraseToAnyPublisher()
    }

    private func createScoreEntities(
        name: String,
        path: String,
        pdfURL: URL,
        parent: Content,
        now: Date
    ) {
        let fileContent = Content(context: context)
        fileContent.id = UUID()
        fileContent.name = name
        fileContent.path = path
        fileContent.type = ContentType.score.rawValue
        fileContent.createdAt = now
        fileContent.modifiedAt = now
        fileContent.lastAccessedAt = now
        fileContent.deletedAt = nil
        fileContent.isStared = false
        fileContent.syncStatus = false
        fileContent.parentContent = parent

        let detail = ScoreDetail(context: context)
        detail.id = UUID()
        detail.key = ""
        detail.t_key = ""
        detail.content = fileContent
        fileContent.scoreDetail = detail

        let pageCount = getPDFPageCount(url: pdfURL)
        for i in 0..<pageCount {
            let page = ScorePage(context: context)
            page.id = UUID()
            page.pageType = "pdf"
            page.originalPageIndex = Int16(i)
            page.displayOrder = Int16(i)
            page.scoreDetail = detail
        }
    }

    private func getPDFPageCount(url: URL) -> Int {
        guard let doc = CGPDFDocument(url as CFURL) else { return 0 }
        return doc.numberOfPages
    }

    private func uniqueFileName(_ name: String, in directory: URL) -> String {
        let fileManager = FileManager.default
        let baseName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        var candidate = name
        var counter = 1
        while fileManager.fileExists(atPath: directory.appendingPathComponent(candidate).path) {
            candidate = ext.isEmpty ? "\(baseName)_\(counter)" : "\(baseName)_\(counter).\(ext)"
            counter += 1
        }
        return candidate
    }
}
