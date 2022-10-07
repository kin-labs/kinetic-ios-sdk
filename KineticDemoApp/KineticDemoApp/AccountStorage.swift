//
//  AccountStorage.swift
//  
//
//  Created by Samuel Dowd on 10/7/22.
//

import Foundation
import Kinetic

public struct AccountStorage {
    public static func getAllAccounts() -> [PublicKey] {
        return accountStorage!.kineticStorage.getAllAccountIds()
    }

    public static func getLocalAccount(_ publicKey: PublicKey? = nil) -> Keypair? {
        let res = accountStorage!.getAccount(publicKey)
        switch res {
        case .success(let account):
            return Keypair(solanaAccount: account)
        case .failure(let e):
            errorLog(e.localizedDescription)
            return nil
        }
    }

    public static func createLocalAccount() -> Keypair? {
        if let account = Account(network: .mainnetBeta) {
            accountStorage!.save(account)
            return Keypair(solanaAccount: account)
        } else { return nil }
    }

    public static func loadAccount(fromMnemonic mnemonic: [String]) -> Keypair? {
        if let account = Account(phrase: mnemonic, network: .mainnetBeta) {
            accountStorage!.save(account)
            return Keypair(solanaAccount: account)
        } else { return nil }
    }

    public static func loadAccount(fromSecret secret: Data) -> Keypair? {
        if let account = Account(secretKey: secret) {
            accountStorage!.save(account)
            return Keypair(solanaAccount: account)
        } else { return nil }
    }
}
