//
//  KineticSdk.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation
import Solana
import Combine

public struct KineticSdk {
    var solana: Solana?
    let sdkConfig: KineticSdkConfig
    internal var internalSdk: KineticSdkInternal

    public init(
        _ sdkConfig: KineticSdkConfig
    ) {
        self.sdkConfig = sdkConfig
        internalSdk = KineticSdkInternal(sdkConfig)
    }

    public var config: AppConfig? {
        internalSdk.appConfig
    }

    public var endpoint: String {
        sdkConfig.endpoint
    }

    public var solanaRpcEndpoint: String? {
        sdkConfig.solanaRpcEndpoint
    }

    public static var logger: AnyPublisher<(KineticLogLevel, String), Never> {
        KineticSdkInternal.logger
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
        let config = try await internalSdk.getAppConfig(environment: sdkConfig.environment, index: sdkConfig.index)
        let rpcEndpoint = sdkConfig.solanaRpcEndpoint != nil ? getSolanaRpcEndpoint(endpoint: sdkConfig.solanaRpcEndpoint!) : getSolanaRpcEndpoint(endpoint: config.environment.cluster.endpoint)
        let networkingRouter = NetworkingRouter(endpoint: rpcEndpoint)
        solana = Solana(router: networkingRouter)

        KineticSdkInternal.debugLog("Initializing \(NAME)@\(VERSION)")
        KineticSdkInternal.debugLog("endpoint: \(sdkConfig.endpoint), environment: \(sdkConfig.environment), index: \(sdkConfig.index)")

        return config
    }

    public static func setup(
        _ sdkConfig: KineticSdkConfig
    ) async throws -> KineticSdk {
        var sdk = KineticSdk(sdkConfig)
        try await sdk.initialize()
        return sdk
    }
}
