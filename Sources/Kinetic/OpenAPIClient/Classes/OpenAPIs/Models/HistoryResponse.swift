//
// HistoryResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct HistoryResponse: Codable, JSONEncodable, Hashable {

    public var account: String
    public var history: [ConfirmedSignatureInfo]

    public init(account: String, history: [ConfirmedSignatureInfo]) {
        self.account = account
        self.history = history
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case account
        case history
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(account, forKey: .account)
        try container.encode(history, forKey: .history)
    }
}

