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
            let encodedAccount = try JSONEncoder().encode(account)
            let accountString = String(data: encodedAccount, encoding: .utf8)!
            try keychain.add(account: account.publicKey.base58EncodedString, key: accountString)
        } catch {
            return .failure(StorageError.unknown)
        }
        return .success(())
    }

    func getAccount(_ publicKey: PublicKey? = nil) -> Result<Account, Error> {
        do {
            let accounts = try keychain.allAccounts()
            if accounts.count == 0 {
                return .failure(StorageError.unknown)
            }
            if let accountJSON = keychain.retrieve(account: publicKey?.base58EncodedString ?? accounts[0]) {
                let accountData = accountJSON.data(using: .utf8)!
                let decodedAccount = try JSONDecoder().decode(Account.self, from: accountData)
                if decodedAccount.phrase.count != 48 { // TODO: Stop Solana SDK from making fake mnemonics and change this check
                    guard let account = Account(phrase: decodedAccount.phrase, network: .mainnetBeta) else {
                        return .failure(StorageError.unknown)
                    }
                    return .success(account)
                } else {
                    guard let account = Account(secretKey: decodedAccount.secretKey) else {
                        return .failure(StorageError.unknown)
                    }
                    return .success(account)
                }
            } else {
                return .failure(StorageError.unknown)
            }
        } catch {
            return .failure(StorageError.unknown)
        }
    }

    var account: Result<Account, Error> {
        return self.getAccount()
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
