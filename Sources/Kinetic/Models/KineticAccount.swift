//
//  KineticAccount.swift
//  
//
//  Created by Samuel Dowd on 8/23/22.
//

import Foundation
import Solana

public struct KineticAccount: Codable, Hashable {
    public let phrase: [String]
    public let publicKey: PublicKey
    public let secretKey: Data

    public init?(phrase: [String] = [], network: Network, derivablePath: DerivablePath? = nil) {
        guard let solanaAccount = Account(phrase: phrase, network: network, derivablePath: derivablePath) else { return nil }
        self.init(solanaAccount: solanaAccount)
    }

    public init?(secretKey: Data) {
        guard let solanaAccount = Account(secretKey: secretKey) else { return nil }
        self.init(solanaAccount: solanaAccount)
    }

    public init?(solanaAccount: Account) {
        self.phrase = solanaAccount.phrase
        self.publicKey = PublicKey(solanaKey: solanaAccount.publicKey)
        self.secretKey = solanaAccount.secretKey
    }

    internal var asSolanaAccount: Account {
        Account(secretKey: self.secretKey)!
    }
}
