//
//  KeychainAccountStorage.swift
//  
//
//  Created by Samuel Dowd on 2/18/22.
//

import Foundation
import Solana

class KeychainAccountStorage: SolanaAccountStorage {

    private enum StorageError: Error {
        case unknown
    }

    private var keychain = KeyChainStorage()
    func save(_ account: Account) -> Result<Void, Error> {
        do {
            try keychain.add(account: account.publicKey.base58EncodedString, key: account.secretKey)
        } catch {
            return .failure(StorageError.unknown)
        }
        return .success(())
    }
    var account: Result<Account, Error> {
        do {
            let accounts = try keychain.allAccounts()
            if accounts.count == 0 {
                return .failure(StorageError.unknown)
            }
            if let pkey = keychain.retrieve(account: accounts[0]) {
                guard let account = Account(secretKey: pkey) else {
                    return .failure(StorageError.unknown)
                }
                return .success(account)
            } else {
                return .failure(StorageError.unknown)
            }
        } catch {
            return .failure(StorageError.unknown)
        }
    }
    func clear() -> Result<Void, Error> {
        do {
            let accounts = try keychain.allAccounts()
            accounts.forEach { (publicKey: String) in
                do {
                    try keychain.delete(account: publicKey)
                } catch { }
            }
            return .success(())
        } catch {
            return .success(())
        }
    }
}
