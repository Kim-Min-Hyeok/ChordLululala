//
//  DropboxImportManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/15/25.
//

import Foundation
import Combine
import CoreData

final class DropboxImportManager {
    static let shared = DropboxImportManager()
    private var context: NSManagedObjectContext { CoreDataManager.shared.context }
    
    private init() {}
    
    func syncCurrentFolderWithFileSystem(parent: Content) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            guard let parentPath = parent.path,
                  let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                promise(.success(()))
                return
            }
            
            let parentURL = docsURL.appendingPathComponent(parentPath, isDirectory: true)
            let fileManager = FileManager.default

            guard let items = try? fileManager.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
                print("❌ [Sync] 파일시스템 항목 읽기 실패: \(parentURL.path)")
                promise(.success(()))
                return
            }

            // 현재 CoreData 목록 캐싱
            let children = ContentCoreDataManager.shared.fetchChildrenSync(for: parent)
            var nameToContent: [String: Content] = [:]
            for content in children {
                nameToContent[content.name ?? ""] = content
            }

            let now = Date()
            var madeFolder = 0
            var madeFile = 0

            for url in items {
                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
                let name = url.lastPathComponent
                let ext = url.pathExtension.lowercased()
                let relPath = parentPath.isEmpty ? name : (parentPath as NSString).appendingPathComponent(name)
                
                // 중복 방지: pdf 변환 후 이름도 미리 고려
                let registerName = (["jpg", "jpeg", "png", "heic"].contains(ext))
                    ? (url.deletingPathExtension().lastPathComponent + ".pdf")
                    : name
                if nameToContent[registerName] != nil {
                    continue
                }

                if isDir.boolValue {
                    let folder = Content(context: CoreDataManager.shared.context)
                    folder.id = UUID()
                    folder.name = name
                    folder.path = relPath
                    folder.type = ContentType.folder.rawValue
                    folder.createdAt = now
                    folder.modifiedAt = now
                    folder.lastAccessedAt = now
                    folder.deletedAt = nil
                    folder.isStared = false
                    folder.syncStatus = false
                    folder.parentContent = parent
                    madeFolder += 1
                    print("📁 [Sync] 폴더 추가: \(relPath)")
                } else if ["jpg", "jpeg", "png", "heic"].contains(ext) {
                    // 이미지: PDF로 변환 후, 원본 삭제 및 PDF만 등록
                    guard let image = UIImage(contentsOfFile: url.path) else { continue }
                    let base = url.deletingPathExtension()
                    let pdfURL = base.appendingPathExtension("pdf")
                    let pdfName = pdfURL.lastPathComponent
                    let pdfRelPath = parentPath.isEmpty ? pdfName : (parentPath as NSString).appendingPathComponent(pdfName)
                    
                    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
                    let pdfData = pdfRenderer.pdfData { ctx in
                        ctx.beginPage()
                        image.draw(in: CGRect(origin: .zero, size: image.size))
                    }
                    do {
                        try pdfData.write(to: pdfURL)
                        try fileManager.removeItem(at: url) // 원본 이미지 삭제
                        print("🖼️→📄 [Sync] 이미지 \(name) → \(pdfName) 변환 및 삭제")
                    } catch {
                        print("❌ [Sync] 이미지 → PDF 변환 실패: \(error)")
                        continue
                    }
                    // PDF 파일만 CoreData에 등록
                    let fileContent = Content(context: CoreDataManager.shared.context)
                    fileContent.id = UUID()
                    fileContent.name = pdfName
                    fileContent.path = pdfRelPath
                    fileContent.type = ContentType.score.rawValue
                    fileContent.createdAt = now
                    fileContent.modifiedAt = now
                    fileContent.lastAccessedAt = now
                    fileContent.deletedAt = nil
                    fileContent.isStared = false
                    fileContent.syncStatus = false
                    fileContent.parentContent = parent
                    madeFile += 1
                    print("📄 [Sync] PDF 추가: \(pdfRelPath)")

                    // ScoreDetail/ScorePage 등록
                    let detail = ScoreDetail(context: CoreDataManager.shared.context)
                    detail.id = UUID()
                    detail.key = ""
                    detail.t_key = ""
                    detail.content = fileContent
                    fileContent.scoreDetail = detail

                    let pageCount = self.getPDFPageCount(url: pdfURL)
                    for i in 0..<pageCount {
                        let page = ScorePage(context: CoreDataManager.shared.context)
                        page.id = UUID()
                        page.pageType = "pdf"
                        page.originalPageIndex = Int16(i)
                        page.displayOrder = Int16(i)
                        page.scoreDetail = detail
                    }
                } else if ext == "pdf" {
                    // PDF는 그대로 등록
                    let fileContent = Content(context: CoreDataManager.shared.context)
                    fileContent.id = UUID()
                    fileContent.name = name
                    fileContent.path = relPath
                    fileContent.type = ContentType.score.rawValue
                    fileContent.createdAt = now
                    fileContent.modifiedAt = now
                    fileContent.lastAccessedAt = now
                    fileContent.deletedAt = nil
                    fileContent.isStared = false
                    fileContent.syncStatus = false
                    fileContent.parentContent = parent
                    madeFile += 1
                    print("📄 [Sync] PDF 추가: \(relPath)")

                    let detail = ScoreDetail(context: CoreDataManager.shared.context)
                    detail.id = UUID()
                    detail.key = ""
                    detail.t_key = ""
                    detail.content = fileContent
                    fileContent.scoreDetail = detail

                    let pageCount = self.getPDFPageCount(url: url)
                    for i in 0..<pageCount {
                        let page = ScorePage(context: CoreDataManager.shared.context)
                        page.id = UUID()
                        page.pageType = "pdf"
                        page.originalPageIndex = Int16(i)
                        page.displayOrder = Int16(i)
                        page.scoreDetail = detail
                    }
                }
                // 기타 파일은 무시
            }

            do {
                try CoreDataManager.shared.context.save()
                print("✅ [Sync] context.save() 완료 (폴더 \(madeFolder), 파일 \(madeFile))")
            } catch {
                print("❌ [Sync] CoreData 저장 오류: \(error)")
            }
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    private func getPDFURL(for content: Content) -> URL? {
        guard let rel = content.path,
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docsURL.appendingPathComponent(rel)
    }
    private func getPDFPageCount(url: URL) -> Int {
        guard let doc = CGPDFDocument(url as CFURL) else { return 0 }
        return doc.numberOfPages
    }
    
    func convertImageToPDFReplacingOriginal(at imageURL: URL) throws {
        // 1. 이미지 로드
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return }

        // 2. PDF 파일명 만들기 (image.png → image.pdf)
        let base = imageURL.deletingPathExtension()
        let pdfURL = base.appendingPathExtension("pdf")

        // 3. PDF 렌더링
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        let pdfData = pdfRenderer.pdfData { ctx in
            ctx.beginPage()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }

        // 4. PDF 파일로 저장
        try pdfData.write(to: pdfURL)

        // 5. 원본 이미지 삭제
        try FileManager.default.removeItem(at: imageURL)
    }
}
