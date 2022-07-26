//
//  ParseKineticSdkEndpoint.swift
//  
//
//  Created by Samuel Dowd on 7/20/22.
//

import Foundation

public func parseKineticSdkEndpoint(_ endpoint: String) throws -> String {
    switch endpoint {
    case "devnet":
        return "https://devnet.kinetic.kin.org"
    case "mainnet", "mainnet-beta":
        return "https://mainnet.kinetic.kin.org"
    default:
        if endpoint.starts(with: "http") {
            return endpoint
        } else {
            throw KineticError.UndefinedEndpointError
        }
    }
}
