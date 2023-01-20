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
    let index: Int
    let headers: Dictionary<String, String>
    let commitment: Commitment?
    let solanaRpcEndpoint: String?

    public init(
        endpoint: String,
        environment: String,
        index: Int,
        headers: Dictionary<String, String> = [:],
        commitment: Commitment? = nil,
        solanaRpcEndpoint: String? = nil
    ) {
        self.endpoint = endpoint
        self.environment = environment
        self.index = index
        self.headers = headers
        self.commitment = commitment
        self.solanaRpcEndpoint = solanaRpcEndpoint
    }
}
