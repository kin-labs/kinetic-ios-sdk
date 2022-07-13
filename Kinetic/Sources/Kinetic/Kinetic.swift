import Solana
import OpenAPIClient
import AnyCodable
import os
import Combine
import Foundation

public struct Kinetic {
    public var logPublisher: AnyPublisher<(KineticLogLevel, String), Never> {
        logSubject.eraseToAnyPublisher()
    }
    private let logSubject = PassthroughSubject<(KineticLogLevel, String), Never>()
    var networkingRouter: NetworkingRouter?
    var accountStorage: KeychainAccountStorage?
    var solana: Solana?
    var environment: String
    var index: Int
    var logger = OSLog.init(subsystem: "org.kinetic.sdk", category: "logs")
    let KIN_MINT = PublicKey(string: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX")
//    let KIN_MINT = PublicKey(string: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6")
    let SAMPLE_WALLET = PublicKey(string: "3rad7aFPdJS3CkYPSphtDAWCNB8BYpV2yc7o5ZjFQbDb")
    let MEMO_V1_PROGRAM_ID = PublicKey(string: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")
    let ASSOCIATED_TOKEN_PROGRAM_ID = PublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!

    public init(environment: String?, index: Int, endpoint: String?) {
        // TODO: add Solana RPC config here
        self.environment = environment ?? "devnet"
        self.index = index
        self.networkingRouter = { switch self.environment {
        case "devnet":
            return NetworkingRouter(endpoint: .devnetSolana)
        case "testnet":
            return NetworkingRouter(endpoint: .testnetSolana)
        default:
            return NetworkingRouter(endpoint: .mainnetBetaSolana)
        } }()
        self.accountStorage = KeychainAccountStorage()
        self.solana = Solana(router: networkingRouter!)
        OpenAPIClientAPI.basePath = endpoint ?? "https://devnet.kinetic.kin.org"
    }

    public func createAccount(account: Account) async throws -> AppTransaction {
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        let mintKey = PublicKey(string: appConfig.mint.publicKey)!
        let feePayer = PublicKey(string: appConfig.mint.feePayer)!
        let latestBlockhashResponse = try await TransactionAPI.getLatestBlockhash(environment: environment, index: index)

        // Get token account
        guard case let .success(associatedTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: account.publicKey, tokenMintAddress: mintKey)
        else {
            throw KineticError.GenerateTokenAccountError
        }

        let memo = try KinBinaryMemo(typeId: KinBinaryMemo.TransferType.none.rawValue, appIdx: UInt16(index))
        let memoData = [UInt8](memo.encode().base64EncodedString().data(using: .utf8)!)
        let memoInstruction = TransactionInstruction(keys: [], programId: MEMO_V1_PROGRAM_ID!, data: memoData)

        // Create Account Instructions
        let minBalanceResult: UInt64? = await withCheckedContinuation { continuation in
            solana!.api.getMinimumBalanceForRentExemption(dataLength: AccountInfo.BUFFER_LENGTH) { res in
                res.onSuccess { minimumBalance in
                    continuation.resume(returning: minimumBalance)
                }
                res.onFailure { e in
                    continuation.resume(returning: nil)
                }
            }
        }
        guard let minimumBalance = minBalanceResult else {
            throw KineticError.GetMinimumBalanceError
        }

        let createAccountInstruction = TransactionInstruction(
            keys: [
                Account.Meta(publicKey: feePayer, isSigner: true, isWritable: true),
                Account.Meta(publicKey: associatedTokenAccount, isSigner: false, isWritable: true),
                Account.Meta(publicKey: account.publicKey, isSigner: true, isWritable: false),
                Account.Meta(publicKey: mintKey, isSigner: false, isWritable: false),
                Account.Meta(publicKey: PublicKey.systemProgramId, isSigner: false, isWritable: false),
                Account.Meta(publicKey: PublicKey.tokenProgramId, isSigner: false, isWritable: false),
                Account.Meta(publicKey: PublicKey.sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: ASSOCIATED_TOKEN_PROGRAM_ID,
            data: []
        )

        var transaction = Transaction(signatures: [
            Transaction.Signature(signature: nil, publicKey: account.publicKey)
        ], feePayer: feePayer, instructions: [
            memoInstruction,
            createAccountInstruction
        ], recentBlockhash: latestBlockhashResponse.blockhash)
        transaction.partialSign(signers: [account])
        let serializedRes: Data? = await withCheckedContinuation { continuation in
            let serializedRes = transaction.serialize(requiredAllSignatures: false, verifySignatures: false)
            switch serializedRes {
            case .success(let serialized):
                continuation.resume(returning: serialized)
            case .failure(let e):
                continuation.resume(returning: nil)
            }
        }
        guard let serialized = serializedRes else {
            throw KineticError.SerializationError
        }
        let createAccountRequest = CreateAccountRequest(environment: environment, index: index, mint: appConfig.mint.symbol, tx: serialized)
        return try await AccountAPI.createAccount(createAccountRequest: createAccountRequest)
    }

    public func getAirdrop(publicKey: String) async throws -> RequestAirdropResponse {
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        return try await AirdropAPI.requestAirdrop(requestAirdropRequest: RequestAirdropRequest(account: publicKey, amount: "100", commitment: .confirmed, environment: environment, index: index, mint: appConfig.mint.symbol))
    }

    public func getAccountBalance(publicKey: String) async throws -> BalanceResponse {
        return try await AccountAPI.getBalance(environment: environment, index: index, accountId: publicKey)
    }

    public func getAccountHistory(publicKey: String) async throws -> [HistoryResponse] {
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        return try await AccountAPI.getHistory(environment: environment, index: index, accountId: publicKey, mint: appConfig.mint.symbol)
    }

    public func getTokenAccounts(publicKey: String) async throws -> [String] {
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        return try await AccountAPI.getTokenAccounts(environment: environment, index: index, accountId: publicKey, mint: appConfig.mint.symbol)
    }

    public func getAppConfig() async throws -> AppConfig {
        debugLog("Getting app config")
        return try await AppAPI.getAppConfig(environment: environment, index: index)
    }

    public func makeTransfer(fromAccount: Account, toPublicKey: PublicKey, amount: Int) async throws -> AppTransaction {
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        let tokenProgramId = PublicKey(string: appConfig.mint.programId)!
        let mintKey = PublicKey(string: appConfig.mint.publicKey)!
        let feePayer = PublicKey(string: appConfig.mint.feePayer)!
        let latestBlockhashResponse = try await TransactionAPI.getLatestBlockhash(environment: environment, index: index)

        // Get token accounts
        guard
            case let .success(fromTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: fromAccount.publicKey, tokenMintAddress: mintKey),
            case let .success(toTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: toPublicKey, tokenMintAddress: mintKey)
        else {
            throw KineticError.GenerateTokenAccountError
        }

        let memo = try KinBinaryMemo(version: 1, typeId: KinBinaryMemo.TransferType.spend.rawValue, appIdx: UInt16(index))
        let memoData = [UInt8](memo.encode().base64EncodedString().data(using: .utf8)!)
        let memoInstruction = TransactionInstruction(keys: [], programId: MEMO_V1_PROGRAM_ID!, data: memoData)
        let sendInstruction = TokenProgram.transferInstruction(
            tokenProgramId: tokenProgramId,
            source: fromTokenAccount,
            destination: toTokenAccount,
            owner: fromAccount.publicKey,
            amount: UInt64(amount)
        )
        var transaction = Transaction(
            signatures: [Transaction.Signature(signature: nil, publicKey: fromAccount.publicKey)],
            feePayer: feePayer,
            instructions: [memoInstruction, sendInstruction],
            recentBlockhash: latestBlockhashResponse.blockhash
        )
        transaction.partialSign(signers: [fromAccount])
        let serializedRes: Data? = await withCheckedContinuation { continuation in
            let serializedRes = transaction.serialize(requiredAllSignatures: false, verifySignatures: false)
            switch serializedRes {
            case .success(let serialized):
                continuation.resume(returning: serialized)
            case .failure(let e):
                continuation.resume(returning: nil)
            }
        }
        guard let serialized = serializedRes else {
            throw KineticError.SerializationError
        }
        let makeTransferRequest = MakeTransferRequest(commitment: .confirmed, environment: environment, index: index, mint: appConfig.mint.symbol, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, referenceId: nil, referenceType: nil, tx: serialized)
        return try await TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest)
    }

    // START: Pre-backend local functions
    public func createAccountLocal() -> Account? {
        let res = accountStorage!.account
        switch res {
            case .success(let account):
                debugLog(String(describing: account))
                return account
            case .failure(let e):
                errorLog(e.localizedDescription)
                let account = Account(network: .mainnetBeta)
                accountStorage!.save(account!)
                return account!
        }
    }

    public func getSOLBalance(callback: @escaping (Int?) -> ()) {
        solana!.api.getBalance(account: SAMPLE_WALLET!.base58EncodedString) { res in
            res.onSuccess { balance in
                callback(Int(balance))
            }
            res.onFailure { e in
                errorLog(e.localizedDescription)
            }
        }


    }

    public func getSPLTokenBalance(token: String, callback: @escaping (Int?) -> ()) {
        solana!.api.getTokenAccountsByOwner(pubkey: SAMPLE_WALLET!.base58EncodedString, mint: KIN_MINT!.base58EncodedString) { (res: Result<[TokenAccount<AccountInfo>], Error>) in
            res.onSuccess { tokenAccounts in
                let tokenAccount = tokenAccounts[0] // Just grabbing one for now
                self.solana!.api.getTokenAccountBalance(pubkey: tokenAccount.pubkey) { res in
                    res.onSuccess { balance in
                        callback(Int(balance.uiAmount ?? 0))
                    }
                    res.onFailure { e in
                        errorLog(e.localizedDescription)
                    }
                }

            }
            res.onFailure { e in
                errorLog(e.localizedDescription)
            }
        }
    }

    public func makeAMemo() {
        let memo = try? KinBinaryMemo(typeId: KinBinaryMemo.TransferType.earn.rawValue, appIdx: UInt16(index))
        infoLog(String(describing: memo))
    }

    private func fixtureTest() {
        let fixtureAccount = Account(phrase: ["pill", "tomorrow", "foster", "begin", "walnut", "borrow", "virtual", "kick", "shift", "mutual", "shoe", "scatter"], network: .mainnetBeta, derivablePath: .default)
        infoLog(fixtureAccount?.publicKey.base58EncodedString ?? "fixture test failed")
    }

    private func debugLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Debug, "KINETIC::D::" + msg))
    }

    private func infoLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Info, "KINETIC::I::" + msg))
    }

    private func warningLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Warning, "KINETIC::W::" + msg))
    }

    private func errorLog(_ msg: String) {
        logSubject.send((KineticLogLevel.Error, "KINETIC::E::" + msg))
    }
}

enum KineticError: Error {
    case GenerateTokenAccountError
    case GetMinimumBalanceError
    case SerializationError
    case UnknownError
}

public enum KineticLogLevel {
    case Debug
    case Info
    case Warning
    case Error
}
