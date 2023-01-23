//
//  ValidateKineticSdkConfig.swift
//
//
//  Created by Samuel Dowd on 1/20/23.
//
import Foundation

public func validateKineticSdkConfig(sdkConfig: KineticSdkConfig) throws -> KineticSdkConfig {
    if !sdkConfig.endpoint.starts(with: "http") {
        throw KineticError.InvalidEndpointError
    }
    if sdkConfig.endpoint.last == "/" {
        let endpoint = String(sdkConfig.endpoint.dropLast(1))
        return KineticSdkConfig(
            endpoint: endpoint,
            environment: sdkConfig.endpoint,
            index: sdkConfig.index,
            headers: sdkConfig.headers,
            commitment: sdkConfig.commitment,
            solanaRpcEndpoint: sdkConfig.solanaRpcEndpoint
        )
    }
    return sdkConfig
}
