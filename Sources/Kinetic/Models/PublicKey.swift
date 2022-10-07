////
////  PublicKey.swift
////  
////
////  Created by Samuel Dowd on 8/23/22.
////
//
//import Foundation
//import struct Solana.PublicKey
//
//public struct PublicKey {
//    public let bytes: [UInt8]
//
//    public init?(bytes: [UInt8]?) {
//        guard let solanaKey = SolanaPublicKey(bytes: bytes) else {
//            return nil
//        }
//        self.init(solanaKey: solanaKey)
//    }
//
//    public init?(string: String) {
//        guard let solanaKey = SolanaPublicKey(string: string) else {
//            return nil
//        }
//        self.init(solanaKey: solanaKey)
//    }
//
//    public init?(data: Data) {
//        guard let solanaKey = SolanaPublicKey(data: data) else {
//            return nil
//        }
//        self.init(solanaKey: solanaKey)
//    }
//
//    internal init(solanaKey: SolanaPublicKey) {
//        self.bytes = solanaKey.bytes
//    }
//
//    public var base58: String {
//        Base58.encode(bytes)
//    }
//
//    public var data: Data {
//        Data(bytes)
//    }
//
//    internal var asSolanaPublicKey: SolanaPublicKey {
//        SolanaPublicKey(bytes: bytes)!
//    }
//}
//
//extension PublicKey: Equatable, CustomStringConvertible, Hashable {
//    public var description: String {
//        base58
//    }
//}
//
//public extension PublicKey {
//    enum PublicKeyError: Error {
//        case invalidPublicKey
//    }
//}
//
//extension PublicKey: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(base58)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let string = try container.decode(String.self)
//        guard string.utf8.count >= SolanaPublicKey.LENGTH else {
//            throw PublicKeyError.invalidPublicKey
//        }
//        self.bytes = Base58.decode(string)
//    }
//}
