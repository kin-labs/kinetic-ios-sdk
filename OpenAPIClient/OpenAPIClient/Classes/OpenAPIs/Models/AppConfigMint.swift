//
// AppConfigMint.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct AppConfigMint: Codable, JSONEncodable, Hashable {

    public var airdrop: Bool
    public var airdropAmount: Double
    public var airdropMax: Double
    public var feePayer: String
    public var logoUrl: String
    public var programId: String
    public var publicKey: String
    public var symbol: String

    public init(airdrop: Bool, airdropAmount: Double, airdropMax: Double, feePayer: String, logoUrl: String, programId: String, publicKey: String, symbol: String) {
        self.airdrop = airdrop
        self.airdropAmount = airdropAmount
        self.airdropMax = airdropMax
        self.feePayer = feePayer
        self.logoUrl = logoUrl
        self.programId = programId
        self.publicKey = publicKey
        self.symbol = symbol
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case airdrop
        case airdropAmount
        case airdropMax
        case feePayer
        case logoUrl
        case programId
        case publicKey
        case symbol
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(airdrop, forKey: .airdrop)
        try container.encode(airdropAmount, forKey: .airdropAmount)
        try container.encode(airdropMax, forKey: .airdropMax)
        try container.encode(feePayer, forKey: .feePayer)
        try container.encode(logoUrl, forKey: .logoUrl)
        try container.encode(programId, forKey: .programId)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(symbol, forKey: .symbol)
    }
}
