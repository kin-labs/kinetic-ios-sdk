//
// CompiledInstruction.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct CompiledInstruction: Codable, JSONEncodable, Hashable {

    public var programIdIndex: Int
    public var accounts: [Int]
    public var data: String

    public init(programIdIndex: Int, accounts: [Int], data: String) {
        self.programIdIndex = programIdIndex
        self.accounts = accounts
        self.data = data
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case programIdIndex
        case accounts
        case data
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(programIdIndex, forKey: .programIdIndex)
        try container.encode(accounts, forKey: .accounts)
        try container.encode(data, forKey: .data)
    }
}
