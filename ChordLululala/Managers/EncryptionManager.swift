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
    
    private let aesKey: SymmetricKey
    
    // 보안 문제보다는 무결성 문제를 해결하기 위한 HMAC 키 (이 키는 공개 되어도 ㄱㅊ)
    private let hmacKey: SymmetricKey = SymmetricKey(data: Data([
        0x23,0xA7,0x5F,0xD1,0xC3,0xE9,0x18,0x4B,
        0x7D,0x90,0xFE,0x61,0x2B,0x5C,0x8E,0x3F,
        0x99,0xDE,0x41,0xB2,0x17,0x6A,0xCE,0x04,
        0x8A,0x3D,0x77,0xF0,0x1E,0xB8,0xCA,0x55
    ]))
    
    private let keyTag = "com.noteflow.chordlululala.encryptionKey"
    
    private init() {
        if let stored = try? KeychainHelper.shared.readKey(tag: keyTag) {
            aesKey = SymmetricKey(data: stored)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let data = newKey.withUnsafeBytes { Data($0) }
            try? KeychainHelper.shared.storeKey(data, tag: keyTag)
            aesKey = newKey
        }
    }
    
    func encrypt(_ data: Data) throws -> Data {
        let box = try AES.GCM.seal(data, using: aesKey)
        guard let combined = box.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined
    }
    func decrypt(_ encrypted: Data) throws -> Data {
        let box = try AES.GCM.SealedBox(combined: encrypted)
        return try AES.GCM.open(box, using: aesKey)
    }
    func encryptFile(at src: URL, to dst: URL) throws {
        let d = try Data(contentsOf: src)
        let e = try encrypt(d)
        try e.write(to: dst, options: .atomic)
    }
    func decryptFile(at src: URL, to dst: URL) throws {
        let d = try Data(contentsOf: src)
        let dec = try decrypt(d)
        try dec.write(to: dst, options: .atomic)
    }
    
    func generateMACFile(at src: URL, to macURL: URL) throws {
        let data = try Data(contentsOf: src)
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: hmacKey)
        try Data(mac).write(to: macURL, options: .atomic)
    }
    
    /// src 파일과 macURL 파일을 비교, 불일치 시 에러 던짐
    func verifyMACFile(at src: URL, macURL: URL) throws {
        let data     = try Data(contentsOf: src)
        let stored   = try Data(contentsOf: macURL)
        let expected = HMAC<SHA256>.authenticationCode(for: data, using: hmacKey)
        guard stored == Data(expected) else {
            throw EncryptionError.macValidationFailed
        }
    }
}

enum EncryptionError: Error {
    case encryptionFailed
    case macValidationFailed
}

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func storeKey(_ key: Data, tag: String) throws {
        let q: [String: Any] = [
            kSecClass              as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData          as String: key,
            kSecAttrAccessible     as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(q as CFDictionary)
        guard SecItemAdd(q as CFDictionary, nil) == errSecSuccess else {
            throw EncryptionError.encryptionFailed
        }
    }
    
    func readKey(tag: String) throws -> Data {
        let q: [String: Any] = [
            kSecClass              as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData         as String: true,
            kSecMatchLimit         as String: kSecMatchLimitOne
        ]
        var res: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &res) == errSecSuccess,
              let data = res as? Data else {
            throw EncryptionError.encryptionFailed
        }
        return data
    }
}
