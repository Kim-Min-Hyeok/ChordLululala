//
//  EncryptionManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/15/25.
//

import Foundation
import CryptoKit

final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private let key: SymmetricKey
    
    private init() {
        // 1) 하드 암호 지정
        let passphrase = "alsgurrla"
        
        // 2) SHA256 해시 생성
        let hash = SHA256.hash(data: Data(passphrase.utf8))
        
        // 3) 해시 바이트를 키로 사용
        self.key = SymmetricKey(data: Data(hash))
    }
    
    func encryptFile(at srcURL: URL, to dstURL: URL) throws {
        let data      = try Data(contentsOf: srcURL)
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        try combined.write(to: dstURL, options: .atomic)
    }
    
    func decryptFile(at srcURL: URL, to dstURL: URL) throws {
        let encrypted = try Data(contentsOf: srcURL)
        let box       = try AES.GCM.SealedBox(combined: encrypted)
        let plain     = try AES.GCM.open(box, using: key)
        try plain.write(to: dstURL, options: .atomic)
    }
}

enum EncryptionError: Error {
    case encryptionFailed
}
