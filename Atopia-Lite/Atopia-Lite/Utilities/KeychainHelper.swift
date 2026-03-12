//
//  KeychainHelper.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/8/26.
//

import Foundation
import Security

/// Thin wrapper around the iOS Keychain for storing login credentials.
struct KeychainHelper {
    private static let service = "com.atopia-lite.credentials"
    
    static func save(username: String, password: String) {
        print("[Keychain] Saving credentials for username: \(username), service: \(service)")
        let passwordData = Data(password.utf8)
        delete()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        print("[Keychain] SecItemAdd status: \(status) (\(status == errSecSuccess ? "success" : "error"))")
    }
    
    static func retrieve() -> (username: String, password: String)? {
        print("[Keychain] Retrieving credentials for service: \(service)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let item = result as? [String: Any],
              let username = item[kSecAttrAccount as String] as? String,
              let passwordData = item[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            print("[Keychain] Retrieve failed: status=\(status)")
            return nil
        }
        
        print("[Keychain] Retrieve success for username: \(username)")
        return (username, password)
    }
    
    static func delete() {
        print("[Keychain] Deleting credentials for service: \(service)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        let status = SecItemDelete(query as CFDictionary)
        print("[Keychain] SecItemDelete status: \(status)")
    }
}
