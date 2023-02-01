import Solana
import os
import Combine
import Foundation

internal struct KineticSdkInternal {
    internal static var logger: AnyPublisher<(KineticLogLevel, String), Never> {
        logSubject.eraseToAnyPublisher()
    }
    private static let logSubject = PassthroughSubject<(KineticLogLevel, String), Never>()
    var solana: Solana?
    var appConfig: AppConfig?
    var sdkConfig: KineticSdkConfig

    internal init(
        _ sdkConfig: KineticSdkConfig
    ) {
        self.sdkConfig = sdkConfig
        OpenAPIClientAPI.basePath = sdkConfig.endpoint
        OpenAPIClientAPI.customHeaders = apiBaseOptions(headers: sdkConfig.headers)
    }

    func createAccount(
        commitment: Commitment?,
        mint: String?,
        owner: Keypair,
        reference: String?
    ) async throws -> Transaction {
        let appConfig = try ensureAppConfig()
        let commitment = getCommitment(commitment: commitment)
        let mint = try getAppMint(appConfig: appConfig, mint: mint)

        let accounts = try await self.getTokenAccounts(account: owner.publicKey, commitment: commitment, mint: mint.publicKey)
        if (!accounts.isEmpty) {
            throw KineticError.TokenAccountAlreadyExistsError
        }

        let latestBlockhashResponse = try await self.getBlockhash()

        let tx = try generateCreateAccountTransaction(addMemo: mint.addMemo, blockhash: latestBlockhashResponse.blockhash, index: sdkConfig.index, mintFeePayer: mint.feePayer, mintPublicKey: mint.publicKey, owner: owner.solana)

        let serialized = try await serializeTransaction(tx)

        let createAccountRequest = CreateAccountRequest(commitment: commitment, environment: sdkConfig.environment, index: sdkConfig.index, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, mint: mint.publicKey, reference: reference, tx: serialized)

        do {
            return try await AccountAPI.createAccount(createAccountRequest: createAccountRequest)
        } catch {
            throw readServerError(error: error)
        }
    }

    mutating func getAppConfig(environment: String, index: Int) async throws -> AppConfig {
        do {
            let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
            self.appConfig = appConfig
            return appConfig
        } catch {
            throw readServerError(error: error)
        }
    }

    func getBalance(account: String, commitment: Commitment?) async throws -> BalanceResponse {
        let commitment = getCommitment(commitment: commitment)
        do {
            return try await AccountAPI.getBalance(environment: sdkConfig.environment, index: sdkConfig.index, accountId: account, commitment: commitment)
        } catch {
            throw readServerError(error: error)
        }
    }

    func getHistory(account: String, commitment: Commitment?, mint: String?) async throws -> [HistoryResponse] {
        let appConfig = try ensureAppConfig()
        let commitment = getCommitment(commitment: commitment)
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        do {
            return try await AccountAPI.getHistory(environment: sdkConfig.environment, index: sdkConfig.index, accountId: account, mint: mint.publicKey, commitment: commitment)
        } catch {
            throw readServerError(error: error)
        }
    }

    func getTokenAccounts(account: String, commitment: Commitment?, mint: String?) async throws -> [String] {
        let appConfig = try ensureAppConfig()
        let commitment = getCommitment(commitment: commitment)
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        do {
            return try await AccountAPI.getTokenAccounts(environment: sdkConfig.environment, index: sdkConfig.index, accountId: account, mint: mint.publicKey, commitment: commitment)
        } catch {
            throw readServerError(error: error)
        }
    }

    func getTransaction(signature: String, commitment: Commitment?) async throws -> GetTransactionResponse {
        let commitment = getCommitment(commitment: commitment)
        do {
            return try await TransactionAPI.getTransaction(environment: sdkConfig.environment, index: sdkConfig.index, signature: signature, commitment: commitment)
        } catch {
            throw readServerError(error: error)
        }
    }

    func makeTransfer(
        amount: String,
        commitment: Commitment?,
        destination: String,
        mint: String?,
        owner: Keypair,
        reference: String?,
        senderCreate: Bool,
        type: KineticKinMemo.TransactionType
    ) async throws -> Transaction {
        let appConfig = try ensureAppConfig()
        let commitment = getCommitment(commitment: commitment)
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        let amount = try addDecimals(amount: amount, decimals: mint.decimals).description

        try self.validateDestination(appConfig: appConfig, destination: destination)

        let accounts = try await self.getTokenAccounts(account: destination, commitment: commitment, mint: mint.publicKey)
        if accounts.isEmpty && !senderCreate {
            throw KineticError.DestinationAccountDoesNotExistError
        }

        let latestBlockhashResponse = try await self.getBlockhash()

        let tx = try generateMakeTransferTransaction(
            addMemo: mint.addMemo,
            amount: amount,
            blockhash: latestBlockhashResponse.blockhash,
            destination: destination,
            index: sdkConfig.index,
            mintDecimals: mint.decimals,
            mintFeePayer: mint.feePayer,
            mintPublicKey: mint.publicKey,
            owner: owner.solana,
            senderCreate: senderCreate,
            type: type
        )

        let makeTransferRequest = try MakeTransferRequest(
            commitment: commitment,
            environment: sdkConfig.environment,
            index: sdkConfig.index,
            mint: mint.publicKey,
            lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight,
            reference: reference,
            tx: await serializeTransaction(tx)
        )

        do {
            return try await TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest)
        } catch {
            throw readServerError(error: error)
        }
    }

    func requestAirdrop(
        account: String,
        amount: String?,
        commitment: Commitment?,
        mint: String?
    ) async throws -> RequestAirdropResponse {
        let appConfig = try ensureAppConfig()
        let commitment = getCommitment(commitment: commitment)
        let mint = try getAppMint(appConfig: appConfig, mint: mint)
        var amount = amount
        if amount != nil {
            amount = try addDecimals(amount: amount!, decimals: mint.decimals).description
        }

        do {
            return try await AirdropAPI.requestAirdrop(requestAirdropRequest: RequestAirdropRequest(
                account: account,
                amount: amount,
                commitment: commitment,
                environment: sdkConfig.environment,
                index: sdkConfig.index,
                mint: mint.publicKey
            ))
        } catch {
            throw readServerError(error: error)
        }
    }

    private func apiBaseOptions(headers: Dictionary<String, String>) -> Dictionary<String, String> {
        return headers.merging([
            "kinetic-environment": sdkConfig.environment,
            "kinetic-index": "\(sdkConfig.index)",
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
        do {
            return try await TransactionAPI.getLatestBlockhash(environment: sdkConfig.environment, index: sdkConfig.index)
        } catch {
            throw readServerError(error: error)
        }
    }

    private func getCommitment(commitment: Commitment?) -> Commitment {
        return commitment ?? sdkConfig.commitment ?? Commitment.confirmed
    }

    private func validateDestination(appConfig: AppConfig, destination: String) throws {
        if (appConfig.mints.contains(where: { mint in
            mint.publicKey == destination
        })) {
            throw KineticError.AttemptedTransferToMintError
        }
    }

    internal func readServerError(error: Error) -> Error {
        switch error as? Kinetic.ErrorResponse {
        case .error(_, let data, _, _):
            if let data = data {
                let realError = String(decoding: data, as: UTF8.self)
                return KineticError.ServerError(realError)
            }
        default:
            return error
        }
        return error
    }

    internal static func debugLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Debug, "KINETIC::D::" + msg))
    }

    internal static func infoLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Info, "KINETIC::I::" + msg))
    }

    internal static func warningLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Warning, "KINETIC::W::" + msg))
    }

    internal static func errorLog(_ msg: String) {
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
    case InvalidAmountError
    case InvalidEndpointError
    case InvalidKeyError
    case InvalidMemoError
    case InvalidMnemonicError
    case InvalidPublicKeyStringError
    case ServerError(String)
    case UnknownError
}

public enum KineticLogLevel {
    case Debug
    case Info
    case Warning
    case Error
}
