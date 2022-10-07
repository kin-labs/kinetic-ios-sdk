//
//  GetSolanaRpcEndpoint.swift
//  
//
//  Created by Samuel Dowd on 7/20/22.
//

import Foundation
import Solana

public func getSolanaRpcEndpoint(endpoint: String) -> RPCEndpoint {
    switch endpoint {
    case "devnet":
        return .devnetSolana
    case "testnet":
        return .testnetSolana
    case "mainnet", "mainnet-beta":
        return .mainnetBetaSolana
    default:
        let webSocketString = endpoint.replacingOccurrences(of: "https", with: "wss").replacingOccurrences(of: "http", with: "wss")
        return RPCEndpoint(url: URL(string: endpoint)!, urlWebSocket: URL(string: webSocketString)!, network: .mainnetBeta)
    }
}
