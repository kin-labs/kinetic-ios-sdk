//
// AppConfigEnvironment.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct AppConfigEnvironment: Codable, JSONEncodable, Hashable {

    public var name: String
    public var explorer: String
    public var cluster: AppConfigCluster

    public init(name: String, explorer: String, cluster: AppConfigCluster) {
        self.name = name
        self.explorer = explorer
        self.cluster = cluster
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case explorer
        case cluster
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(explorer, forKey: .explorer)
        try container.encode(cluster, forKey: .cluster)
    }
}
