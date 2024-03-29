//
// AppHealth.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct AppHealth: Codable, JSONEncodable, Hashable {

    public var isSolanaOk: Bool
    public var isKineticOk: Bool
    public var time: Date

    public init(isSolanaOk: Bool, isKineticOk: Bool, time: Date) {
        self.isSolanaOk = isSolanaOk
        self.isKineticOk = isKineticOk
        self.time = time
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case isSolanaOk
        case isKineticOk
        case time
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isSolanaOk, forKey: .isSolanaOk)
        try container.encode(isKineticOk, forKey: .isKineticOk)
        try container.encode(time, forKey: .time)
    }
}

