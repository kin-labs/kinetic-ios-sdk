//
// ConfirmedTransactionMeta.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct ConfirmedTransactionMeta: Codable, JSONEncodable, Hashable {

    public var fee: Double?
    public var innerInstructions: [String]
    public var preBalances: [String]
    public var postBalances: [String]
    public var logMessages: [String]?
    public var preTokenBalances: [String]?
    public var postTokenBalances: [String]?
    public var err: AnyCodable?

    public init(fee: Double? = nil, innerInstructions: [String], preBalances: [String], postBalances: [String], logMessages: [String]? = nil, preTokenBalances: [String]? = nil, postTokenBalances: [String]? = nil, err: AnyCodable? = nil) {
        self.fee = fee
        self.innerInstructions = innerInstructions
        self.preBalances = preBalances
        self.postBalances = postBalances
        self.logMessages = logMessages
        self.preTokenBalances = preTokenBalances
        self.postTokenBalances = postTokenBalances
        self.err = err
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case fee
        case innerInstructions
        case preBalances
        case postBalances
        case logMessages
        case preTokenBalances
        case postTokenBalances
        case err
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fee, forKey: .fee)
        try container.encode(innerInstructions, forKey: .innerInstructions)
        try container.encode(preBalances, forKey: .preBalances)
        try container.encode(postBalances, forKey: .postBalances)
        try container.encodeIfPresent(logMessages, forKey: .logMessages)
        try container.encodeIfPresent(preTokenBalances, forKey: .preTokenBalances)
        try container.encodeIfPresent(postTokenBalances, forKey: .postTokenBalances)
        try container.encodeIfPresent(err, forKey: .err)
    }
}
