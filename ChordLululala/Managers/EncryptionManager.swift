//
//  EncryptionManager.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/15/25.
//

import Foundation
import CryptoKit

/// 암호화 및 복호화를 담당하는 매니저
final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private let key: SymmetricKey
    private let keyTag = "com.noteflow.chordlululala.encryptionKey"
    
    private init() {
        if let storedKey = try? KeychainHelper.shared.readKey(tag: keyTag) {
            key = SymmetricKey(data: storedKey)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try? KeychainHelper.shared.storeKey(keyData, tag: keyTag)
            key = newKey
        }
    }
    
    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined
    }
    
    func decrypt(_ encryptedData: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func encryptFile(at srcURL: URL, to dstURL: URL) throws {
        let data = try Data(contentsOf: srcURL)
        let encrypted = try encrypt(data)
        try encrypted.write(to: dstURL, options: .atomic)
    }
    
    func decryptFile(at srcURL: URL, to dstURL: URL) throws {
        let data = try Data(contentsOf: srcURL)
        let decrypted = try decrypt(data)
        try decrypted.write(to: dstURL, options: .atomic)
    }
}

enum EncryptionError: Error {
    case encryptionFailed
}

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    func storeKey(_ key: Data, tag: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.encryptionFailed
        }
    }

    func readKey(tag: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            throw EncryptionError.encryptionFailed
        }
        return data
    }
}
