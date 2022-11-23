//
//  Keypair.swift
//  
//
//  Created by Samuel Dowd on 8/23/22.
//

import Foundation
//@_exported import Solana
import Solana

public struct Keypair: Codable, Hashable {
    internal let solanaKeypair: HotAccount
    public var mnemonic: [String]?
    public let publicKey: String
    public let secretKey: String?

    public init(secretKey: String) throws {
        self.solanaKeypair = HotAccount(secretKey: Data(Base58.decode(secretKey)))!
        self.publicKey = solanaKeypair.publicKey.base58EncodedString
        self.secretKey = Base58.encode(solanaKeypair.secretKey.bytes)
    }

    internal init(solanaAccount: HotAccount) {
        self.solanaKeypair = solanaAccount
        self.publicKey = solanaKeypair.publicKey.base58EncodedString
        self.secretKey = Base58.encode(solanaKeypair.secretKey.bytes)
    }

    public var solana: HotAccount {
        solanaKeypair
    }

    internal var solanaPublicKey: SolanaPublicKey {
        solanaKeypair.publicKey
    }

    public var solanaSecretKey: Data {
        solanaKeypair.secretKey
    }

    public static func fromByteArray(_ byteArray: Data) throws -> Keypair {
        return try Keypair.fromSecretKey(Base58.encode(byteArray.bytes))
    }

//    public static func fromMnemonicSeed(_ mnemonic: [String]) -> Keypair {
//    TODO: Not implemented
//    }

    public static func fromMnemonic(_ mnemonic: [String]) throws -> Keypair {
        return try self.fromMnemonicSet(mnemonic)[0]
    }

    public static func fromMnemonicSet(_ mnemonic: [String], from: Int = 0, to: Int = 10) throws -> [Keypair] {
        // Always start with zero as minimum
        let from = from < 0 ? 0 : from
        // Always generate at least 1
        let to = to <= from ? from + 1 : to

        let mnemonic = Mnemonic(phrase: mnemonic)!
        var keys: [Keypair] = []

        for i in from..<to {
            var kp = try Keypair.derive(seed: mnemonic.seed, walletIndex: i)
            kp.mnemonic = mnemonic.phrase
            keys.append(kp)
        }

        return keys
    }

    public static func derive(seed: [UInt8], walletIndex: Int) throws -> Keypair {
        let mnemonic = Mnemonic(entropy: seed)!
        let solanaKeypair = HotAccount(phrase: mnemonic.phrase, network: .devnet, derivablePath: DerivablePath(type: .bip44Change, walletIndex: walletIndex))!
        var kp = try Keypair(secretKey: Base58.encode(solanaKeypair.secretKey.bytes))
        kp.mnemonic = mnemonic.phrase
        return kp
    }

    public static func fromSeed(seed: [UInt8]) throws -> Keypair {
        return try Keypair.derive(seed: seed, walletIndex: 0)
    }

    public static func fromSecretKey(_ secretKey: String) throws -> Keypair {
        return try Keypair(secretKey: secretKey)
    }

    public static func random() -> Keypair {
        let mnemonic = self.generateMnemonic()
        return try! self.fromMnemonic(mnemonic)
    }

    public static func generateMnemonic(strength: Int = 128) -> [String] {
        return Mnemonic(strength: strength).phrase
    }
}
