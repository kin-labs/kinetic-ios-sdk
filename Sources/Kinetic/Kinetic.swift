import Solana
//import OpenAPIClient
//import AnyCodable
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
    var appConfig: AppConfig!
    let KIN_MINT = SolanaPublicKey(string: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX")
//    let KIN_MINT = PublicKey(string: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6")
    let SAMPLE_WALLET = SolanaPublicKey(string: "3rad7aFPdJS3CkYPSphtDAWCNB8BYpV2yc7o5ZjFQbDb")
    let MEMO_V1_PROGRAM_ID = SolanaPublicKey(string: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")
    let ASSOCIATED_TOKEN_PROGRAM_ID = SolanaPublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!

    public init(environment: String?, index: Int, endpoint: String?, fileDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("kinetic")) {
        self.environment = environment ?? "devnet"
        self.index = index
        let rpcEndpoint = getSolanaRpcEndpoint(environment: self.environment)
        self.networkingRouter = NetworkingRouter(endpoint: rpcEndpoint)
        self.accountStorage = KeychainAccountStorage(fileDirectory: fileDirectory)
        self.solana = Solana(router: networkingRouter!)
        OpenAPIClientAPI.basePath = endpoint ?? "https://devnet.kinetic.kin.org"
    }

    public func createAccount(account: KineticAccount, mint: AppConfigMint? = nil) async throws -> Transaction {
        let account = account.asSolanaAccount
        let mint = mint ?? appConfig.mint
        let mintKey = SolanaPublicKey(string: mint.publicKey)!
        let feePayer = SolanaPublicKey(string: mint.feePayer)!
        let latestBlockhashResponse = try await TransactionAPI.getLatestBlockhash(environment: environment, index: index)

        // Get token account
        guard case let .success(associatedTokenAccount) = SolanaPublicKey.associatedTokenAddress(walletAddress: account.publicKey as SolanaPublicKey, tokenMintAddress: mintKey)
        else {
            throw KineticError.GenerateTokenAccountError
        }

        let memo = try KineticKinMemo(typeId: KineticKinMemo.TransferType.none.rawValue, appIdx: UInt16(index))
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
                Account.Meta(publicKey: SolanaPublicKey.systemProgramId, isSigner: false, isWritable: false),
                Account.Meta(publicKey: SolanaPublicKey.tokenProgramId, isSigner: false, isWritable: false),
                Account.Meta(publicKey: SolanaPublicKey.sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: ASSOCIATED_TOKEN_PROGRAM_ID,
            data: []
        )

        var transaction = SolanaTransaction(signatures: [
            SolanaTransaction.Signature(signature: nil, publicKey: account.publicKey)
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
        let createAccountRequest = CreateAccountRequest(commitment: .confirmed, environment: environment, index: index, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, mint: appConfig.mint.publicKey, tx: serialized)
        return try await AccountAPI.createAccount(createAccountRequest: createAccountRequest)
    }

    public func getAirdrop(publicKey: String, amount: Int? = nil, commitment: RequestAirdropRequest.Commitment = .finalized, mint: AppConfigMint? = nil) async throws -> RequestAirdropResponse {
        let mint = mint ?? appConfig.mint
        return try await AirdropAPI.requestAirdrop(requestAirdropRequest: RequestAirdropRequest(account: publicKey, amount: amount != nil ? String(intValue: amount!) : nil, commitment: commitment, environment: environment, index: index, mint: mint.publicKey))
    }

    public func getAccountBalance(publicKey: PublicKey) async throws -> BalanceResponse {
        return try await AccountAPI.getBalance(environment: environment, index: index, accountId: publicKey.base58)
    }

    public func getAccountHistory(publicKey: PublicKey, mint: AppConfigMint? = nil) async throws -> [HistoryResponse] {
        let mint = mint ?? appConfig.mint
        return try await AccountAPI.getHistory(environment: environment, index: index, accountId: publicKey.base58, mint: mint.publicKey)
    }

    public func getTokenAccounts(publicKey: PublicKey, mint: AppConfigMint? = nil) async throws -> [String] {
        let mint = mint ?? appConfig.mint
        return try await AccountAPI.getTokenAccounts(environment: environment, index: index, accountId: publicKey.base58, mint: mint.publicKey)
    }

    public func getAppConfig() async throws -> AppConfig {
        debugLog("Getting app config")
        let appConfig = try await AppAPI.getAppConfig(environment: environment, index: index)
        return appConfig
    }

    public func makeTransfer(fromAccount: KineticAccount, toPublicKey: PublicKey, amount: Int, commitment: MakeTransferRequest.Commitment = .confirmed, mint: AppConfigMint? = nil, referenceId: String? = nil, referenceType: String? = nil, type: KineticKinMemo.TransferType = .none) async throws -> Transaction {
        let fromAccount = fromAccount.asSolanaAccount
        let toPublicKey = toPublicKey.asSolanaPublicKey
        let mint = mint ?? appConfig.mint
        let tokenProgramId = SolanaPublicKey(string: mint.programId)!
        let mintKey = SolanaPublicKey(string: mint.publicKey)!
        let feePayer = SolanaPublicKey(string: mint.feePayer)!
        let latestBlockhashResponse = try await TransactionAPI.getLatestBlockhash(environment: environment, index: index)

        // Get token accounts
        guard
            case let .success(fromTokenAccount) = SolanaPublicKey.associatedTokenAddress(walletAddress: fromAccount.publicKey, tokenMintAddress: mintKey),
            case let .success(toTokenAccount) = SolanaPublicKey.associatedTokenAddress(walletAddress: toPublicKey, tokenMintAddress: mintKey)
        else {
            throw KineticError.GenerateTokenAccountError
        }

        let memo = try KineticKinMemo(version: 1, typeId: type.rawValue, appIdx: UInt16(index))
        let memoData = [UInt8](memo.encode().base64EncodedString().data(using: .utf8)!)
        let memoInstruction = TransactionInstruction(keys: [], programId: MEMO_V1_PROGRAM_ID!, data: memoData)
        let sendInstruction = TokenProgram.transferCheckedInstruction(
            programId: tokenProgramId,
            source: fromTokenAccount,
            mint: mintKey,
            destination: toTokenAccount,
            owner: fromAccount.publicKey,
            multiSigners: [],
            amount: UInt64(amount),
            decimals: UInt8(mint.decimals)
        )
        var transaction = SolanaTransaction(
            signatures: [SolanaTransaction.Signature(signature: nil, publicKey: fromAccount.publicKey)],
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
        let makeTransferRequest = MakeTransferRequest(commitment: commitment, environment: environment, index: index, mint: mint.publicKey, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, referenceId: referenceId, referenceType: referenceType, tx: serialized)
        return try await TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest)
    }

    // START: Local account storage functions
    public func getAllAccounts() -> [PublicKey] {
        return accountStorage!.kineticStorage.getAllAccountIds()
    }
    
    public func getLocalAccount(_ publicKey: PublicKey? = nil) -> KineticAccount? {
        let res = accountStorage!.getAccount(publicKey)
        switch res {
        case .success(let account):
            return KineticAccount(solanaAccount: account)
        case .failure(let e):
            errorLog(e.localizedDescription)
            return nil
        }
    }

    public func createLocalAccount() -> KineticAccount? {
        if let account = Account(network: .mainnetBeta) {
            accountStorage!.save(account)
            return KineticAccount(solanaAccount: account)
        } else { return nil }
    }

    public func loadAccount(fromMnemonic mnemonic: [String]) -> KineticAccount? {
        if let account = Account(phrase: mnemonic, network: .mainnetBeta) {
            accountStorage!.save(account)
            return KineticAccount(solanaAccount: account)
        } else { return nil }
    }

    public func loadAccount(fromSecret secret: Data) -> KineticAccount? {
        if let account = Account(secretKey: secret) {
            accountStorage!.save(account)
            return KineticAccount(solanaAccount: account)
        } else { return nil }
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
        let memo = try? KineticKinMemo(typeId: KineticKinMemo.TransferType.earn.rawValue, appIdx: UInt16(index))
        infoLog(String(describing: memo))
    }

    private func fixtureTest() {
        let fixtureAccount = Account(phrase: ["pill", "tomorrow", "foster", "begin", "walnut", "borrow", "virtual", "kick", "shift", "mutual", "shoe", "scatter"], network: .mainnetBeta, derivablePath: .default)
        infoLog(fixtureAccount?.publicKey.base58EncodedString ?? "fixture test failed")
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
    case GetMinimumBalanceError
    case SerializationError
    case UndefinedEndpointError
    case UnknownError
}

public enum KineticLogLevel {
    case Debug
    case Info
    case Warning
    case Error
}
