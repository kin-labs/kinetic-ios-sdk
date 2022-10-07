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

    internal var kineticStorage: KineticStorage

    public init(fileDirectory: URL) {
        self.kineticStorage = KineticStorage(directory: fileDirectory)
    }

    func save(_ account: Account) -> Result<Void, Error> {
        do {
            try kineticStorage.addAccount(account)
        } catch {
            return .failure(StorageError.unknown)
        }
        return .success(())
    }

    func getAccount(_ publicKey: PublicKey? = nil) -> Result<Account, Error> {
        let accounts = kineticStorage.getAllAccountIds()
        print(accounts)
        if accounts.count == 0 {
            return .failure(StorageError.unknown)
        }
        if let account = kineticStorage.getAccount(publicKey ?? accounts[0]) {
            return .success(account)
        } else {
            return .failure(StorageError.unknown)
        }
    }

    var account: Result<Account, Error> {
        return self.getAccount()
    }

    func clear() -> Result<Void, Error> {
        do {
            try kineticStorage.clearStorage()
            return .success(())
        } catch {
            return .success(())
        }
    }
}
