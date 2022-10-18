//
//  SecureKeyStorage.swift
//  Kinetic
//
//  Created by Kik Interactive Inc. on 2020-02-14.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

internal enum KeyStoreError: Error {
    case error(from: OSStatus)
}

internal protocol SecureKeyStorage {
    /// Adds a pair of account and key data to secure storage, updates the old key if the account exists.
    /// - Parameters:
    ///   - publicKey: A string that uniquely identifies the account.
    ///   - secret: A piece of data. Caller is responsible for determining what data needs to be stored securely and the encoding/decoding of this key.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func add(publicKey: String, secret: String) throws

    /// Retrieves key data from secure storage base on account.
    /// - Parameter publicKey: The string identifier that was used when adding key.
    /// - Returns: The stored key data with the account if exists.
    func retrieve(publicKey: String) -> String?

    /// Returns all account identifiers in the storage.
    /// - Returns: A string array of all account identifiers stored.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func allKeys() throws -> [String]

    /// Deletes an account from storage. This action is **irreversible**. Make sure the account has been backed up beforehand.
    /// - Parameter publicKey: The string identifier that was used when adding key.
    /// - Warning: This action is **irreversible**. Calling this action would remove your key(e.g. private key). Make sure the account has been backed up
    ///             beforehand.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func delete(publicKey: String) throws

    /// Clears the entire storage. This action is **irreversible** . Make sure the accounts have been backed up beforehand.
    /// - Warning: This action is **irreversible**. Calling this action would remove all keys(e.g. private key). Make sure the accounts have been backed
    ///             up beforehand.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func clear() throws
}

/// Uses KeyChain in Security framework to implement on-device secure storage of keys. These keys are accessable only by the hosting app when the device
/// is unlocked.
class KeyChainStorage: SecureKeyStorage {

    func add(publicKey: String, secret: String) throws {
        if retrieve(publicKey: publicKey) != nil {
            try? update(publicKey: publicKey, secret: secret)
            return
        }

        let addquery: [String: Any] = [
            String(kSecClass):          kSecClassGenericPassword,
            String(kSecAttrAccount):    publicKey,
            String(kSecValueData):      secret.data(using: .utf8)!
        ]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeyStoreError.error(from: status)
        }
    }

    func retrieve(publicKey: String) -> String? {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword,
            String(kSecAttrAccount):  publicKey,
            String(kSecReturnData):   true,
            String(kSecMatchLimit):   kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(decoding: data, as: UTF8.self)
    }

    func allKeys() throws -> [String] {
        let query: [String: Any] = [
            String(kSecClass):              kSecClassGenericPassword,
            String(kSecReturnAttributes):   true,
            String(kSecMatchLimit):         kSecMatchLimitAll
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyStoreError.error(from: status)
        }

        guard let items = result as? [[String: AnyObject]] else {
            return []
        }

        let accounts = items.compactMap { (item) -> String? in
            return item[String(kSecAttrAccount)] as? String
        }

        return accounts
    }

    func delete(publicKey: String) throws {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword,
            String(kSecAttrAccount):  publicKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeyStoreError.error(from: status)
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeyStoreError.error(from: status)
        }
    }

    private func update(publicKey: String, secret: String) throws {
        let query: [String: Any] = [
            String(kSecClass):          kSecClassGenericPassword,
            String(kSecAttrAccount):    publicKey
        ]

        let attrToUpdate: [String: Any] = [
            String(kSecValueData):      secret
        ]

        let status = SecItemUpdate(query as CFDictionary,
                                   attrToUpdate as CFDictionary)
        if status != errSecSuccess {
            throw KeyStoreError.error(from: status)
        }
    }
}
