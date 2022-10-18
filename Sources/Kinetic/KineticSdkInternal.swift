import Solana
import os
import Combine
import Foundation

internal struct KineticSdkInternal {
    internal var logger: AnyPublisher<(KineticLogLevel, String), Never> {
        logSubject.eraseToAnyPublisher()
    }
    private let logSubject = PassthroughSubject<(KineticLogLevel, String), Never>()
    var solana: Solana?
    var environment: String
    var endpoint: String
    var index: Int
    var appConfig: AppConfig?

    internal init(
        endpoint: String,
        environment: String,
        headers: Dictionary<String, String>,
        index: Int
    ) {
        self.endpoint = endpoint
        self.environment = environment
        self.index = index

        OpenAPIClientAPI.basePath = endpoint
        OpenAPIClientAPI.customHeaders = apiBaseOptions(headers: headers)
    }

    func createAccount(
        commitment: Commitment,
        mint: String?,
        owner: Keypair,
        referenceId: String?,
        referenceType: String?
    ) async throws -> Transaction {
        let appConfig = try ensureAppConfig()
        let mint = try getAppMint(appConfig: appConfig, mint: mint)

        let accounts = try await self.getTokenAccounts(account: owner.publicKey, mint: mint.publicKey)
        if (!accounts.isEmpty) {
            throw KineticError.TokenAccountAlreadyExistsError
        }

        let latestBlockhashResponse = try await self.getBlockhash()

        let tx = try generateCreateAccountTransaction(addMemo: mint.addMemo, blockhash: latestBlockhashResponse.blockhash, index: index, mintFeePayer: mint.feePayer, mintPublicKey: mint.publicKey, owner: owner.solana)

        let serialized = try await serializeTransaction(tx)

        let createAccountRequest = CreateAccountRequest(commitment: commitment, environment: environment, index: index, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, mint: mint.publicKey, referenceId: referenceId, referenceType: referenceType, tx: serialized)

        return try await AccountAPI.createAccount(createAccountRequest: createAccountRequest)
    }

    mutating func getAppConfig(environment: String, index: Int) async throws -> AppConfig {
        debugLog("Testingtesting")
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        self.appConfig = appConfig
        return appConfig
    }

    func getBalance(account: String) async throws -> BalanceResponse {
        return try await AccountAPI.getBalance(environment: environment, index: index, accountId: account)
    }

    func getHistory(account: String, mint: String?) async throws -> [HistoryResponse] {
        let appConfig = try ensureAppConfig()
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        return try await AccountAPI.getHistory(environment: environment, index: index, accountId: account, mint: mint.publicKey)
    }

    func getTokenAccounts(account: String, mint: String?) async throws -> [String] {
        let appConfig = try ensureAppConfig()
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        return try await AccountAPI.getTokenAccounts(environment: environment, index: index, accountId: account, mint: mint.publicKey)
    }

    func getTransaction(signature: String) async throws -> GetTransactionResponse {
        return try await TransactionAPI.getTransaction(environment: environment, index: index, signature: signature)
    }

    func makeTransfer(
        amount: String,
        commitment: Commitment,
        destination: String,
        mint: String?,
        owner: Keypair,
        referenceId: String?,
        referenceType: String?,
        senderCreate: Bool,
        type: KineticKinMemo.TransactionType
    ) async throws -> Transaction {
        let appConfig = try ensureAppConfig()
        let mint = try getAppMint(appConfig: appConfig, mint: mint)

        try self.validateDestination(appConfig: appConfig, destination: destination)

        let accounts = try await self.getTokenAccounts(account: destination, mint: mint.publicKey)
        if accounts.isEmpty && !senderCreate {
            throw KineticError.DestinationAccountDoesNotExistError
        }

        let latestBlockhashResponse = try await self.getBlockhash()

        let tx = try generateMakeTransferTransaction(
            addMemo: mint.addMemo,
            amount: amount,
            blockhash: latestBlockhashResponse.blockhash,
            destination: destination,
            index: index,
            mintDecimals: mint.decimals,
            mintFeePayer: mint.feePayer,
            mintPublicKey: mint.publicKey,
            owner: owner.solana,
            senderCreate: senderCreate,
            type: type
        )

        let makeTransferRequest = try MakeTransferRequest(
            commitment: commitment,
            environment: environment,
            index: index,
            mint: mint.publicKey,
            lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight,
            referenceId: referenceId,
            referenceType: referenceType,
            tx: await serializeTransaction(tx)
        )
        return try await TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest)
    }

    func requestAirdrop(
        account: String,
        amount: String?,
        commitment: Commitment,
        mint: String?
    ) async throws -> RequestAirdropResponse {
        let appConfig = try ensureAppConfig()
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        return try await AirdropAPI.requestAirdrop(requestAirdropRequest: RequestAirdropRequest(
            account: account,
            amount: amount,
            commitment: commitment,
            environment: environment,
            index: index,
            mint: mint.publicKey
        ))
    }

    private func apiBaseOptions(headers: Dictionary<String, String>) -> Dictionary<String, String> {
        return headers.merging([
            "kinetic-environment": environment,
            "kinetic-index": "\(index)",
            "kinetic-user-agent": "\(NAME)@\(VERSION)"
        ], uniquingKeysWith: { current, _ in
            current
        })
    }

    private func ensureAppConfig() throws -> AppConfig {
        guard let appConfig = appConfig else {
            throw KineticError.AppConfigNotInitializedError
        }
        return appConfig
    }

    private func getAppMint(appConfig: AppConfig, mint: String?) throws -> AppConfigMint {
        let mint = mint ?? appConfig.mint.publicKey
        let found = appConfig.mints.firstIndex { item in
            item.publicKey == mint
        }
        if found == nil {
            throw KineticError.MintNotFoundError
        }
        return appConfig.mints[found!]
    }

    private func getBlockhash() async throws -> LatestBlockhashResponse {
       return try await TransactionAPI.getLatestBlockhash(environment: environment, index: index)
    }

    private func validateDestination(appConfig: AppConfig, destination: String) throws {
        if (appConfig.mints.contains(where: { mint in
            mint.publicKey == destination
        })) {
            throw KineticError.AttemptedTransferToMintError
        }
    }

    internal func debugLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Debug, "KINETIC::D::" + msg))
    }

    internal func infoLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Info, "KINETIC::I::" + msg))
    }

    internal func warningLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Warning, "KINETIC::W::" + msg))
    }

    internal func errorLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Error, "KINETIC::E::" + msg))
    }
}

enum KineticError: Error {
    case GenerateTokenAccountError
    case TokenAccountAlreadyExistsError
    case SerializationError
    case UndefinedEndpointError
    case AppConfigNotInitializedError
    case MintNotFoundError
    case AttemptedTransferToMintError
    case DestinationAccountDoesNotExistError
    case UnknownError
}

public enum KineticLogLevel {
    case Debug
    case Info
    case Warning
    case Error
}
