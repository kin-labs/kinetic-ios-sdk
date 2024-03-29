//
// AirdropStats.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct AirdropStats: Codable, JSONEncodable, Hashable {

    public var counts: AirdropStatsCounts
    public var dates: [AirdropStatsDate]

    public init(counts: AirdropStatsCounts, dates: [AirdropStatsDate]) {
        self.counts = counts
        self.dates = dates
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case counts
        case dates
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(counts, forKey: .counts)
        try container.encode(dates, forKey: .dates)
    }
}

