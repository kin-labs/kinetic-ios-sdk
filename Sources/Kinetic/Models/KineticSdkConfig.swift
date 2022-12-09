//
//  KineticSdkConfig.swift
//  
//
//  Created by Samuel Dowd on 12/8/22.
//

import Foundation

public struct KineticSdkConfig {
    let endpoint: String
    let environment: String
    let headers: Dictionary<String, String>
    let index: Int
    let solanaRpcEndpoint: String?

    public init(endpoint: String, environment: String, headers: Dictionary<String, String> = [:], index: Int, solanaRpcEndpoint: String? = nil) {
        self.endpoint = endpoint
        self.environment = environment
        self.headers = headers
        self.index = index
        self.solanaRpcEndpoint = solanaRpcEndpoint
    }
}
