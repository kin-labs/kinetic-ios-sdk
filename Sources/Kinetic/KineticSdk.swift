//
//  KineticSdk.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation
import Solana

public struct KineticSdk {
    var solana: Solana?
    internal var internalSdk: KineticSdkInternal
    var endpoint: String
    var environment: String
    var headers: Dictionary<String, String>
    var index: Int
    var logger: Any?
    var solanaRpcEndpoint: String?

    public init(
        endpoint: String,
        environment: String,
        headers: Dictionary<String, String> = [:],
        index: Int,
        logger: Any?,
        solanaRpcEndpoint: String?
    ) {
        internalSdk = KineticSdkInternal(
            endpoint: endpoint,
            environment: environment,
            headers: headers,
            index: index,
            logger: logger
        )
        self.endpoint = endpoint
        self.environment = environment
        self.headers = headers
        self.index = index
        self.logger = logger
        self.solanaRpcEndpoint = solanaRpcEndpoint
    }

    var config: AppConfig? {
        internalSdk.appConfig
    }

    public func createAccount(
        commitment: Commitment = .confirmed,
        mint: String? = nil,
        owner: Keypair,
        referenceId: String? = nil,
        referenceType: String? = nil
    ) async throws -> Transaction {
        return try await internalSdk.createAccount(
            commitment: commitment,
            mint: mint,
            owner: owner,
            referenceId: referenceId,
            referenceType: referenceType
        )
    }

    public func getBalance(account: String) async throws -> BalanceResponse {
        return try await internalSdk.getBalance(account: account)
    }

    public func getExplorerUrl(path: String) -> String? {
        return internalSdk.appConfig?.environment.explorer.replacingOccurrences(of: "{path}", with: path)
    }

    public func getHistory(account: String, mint: String? = nil) async throws -> [HistoryResponse] {
        return try await internalSdk.getHistory(account: account, mint: mint)
    }

    public func getTokenAccounts(account: String, mint: String? = nil) async throws -> [String] {
        return try await internalSdk.getTokenAccounts(account: account, mint: mint)
    }

    public func getTransaction(signature: String) async throws -> GetTransactionResponse {
        return try await internalSdk.getTransaction(signature: signature)
    }

    public func makeTransfer(
        amount: String,
        commitment: Commitment = .confirmed,
        destination: String,
        mint: String? = nil,
        owner: Keypair,
        referenceId: String? = nil,
        referenceType: String? = nil,
        senderCreate: Bool = false,
        type: KineticKinMemo.TransactionType = .none
    ) async throws -> Transaction {
        return try await internalSdk.makeTransfer(
            amount: amount,
            commitment: commitment,
            destination: destination,
            mint: mint,
            owner: owner,
            referenceId: referenceId,
            referenceType: referenceType,
            senderCreate: senderCreate,
            type: type
        )
    }

    public func requestAirdrop(
        account: String,
        amount: String? = nil,
        commitment: Commitment = .finalized,
        mint: String? = nil
    ) async throws -> RequestAirdropResponse {
        return try await internalSdk.requestAirdrop(
            account: account,
            amount: amount,
            commitment: commitment,
            mint: mint
        )
    }

    public mutating func initialize() async throws -> AppConfig {
//            self.internalSdk.logger?
        let config = try await internalSdk.getAppConfig(environment: environment, index: index)
        let rpcEndpoint = solanaRpcEndpoint != nil ? getSolanaRpcEndpoint(endpoint: solanaRpcEndpoint!) : getSolanaRpcEndpoint(endpoint: config.environment.cluster.endpoint)
        let networkingRouter = NetworkingRouter(endpoint: rpcEndpoint)
        solana = Solana(router: networkingRouter)
        return config
    }

    public static func setup(
        endpoint: String,
        environment: String,
        headers: Dictionary<String, String> = [:],
        index: Int,
        logger: Any?,
        solanaRpcEndpoint: String?
    ) async throws -> KineticSdk {
        var sdk = KineticSdk(
            endpoint: endpoint,
            environment: environment,
            headers: headers,
            index: index,
            logger: logger,
            solanaRpcEndpoint: solanaRpcEndpoint
        )
        try await sdk.initialize()
        return sdk
    }
}
