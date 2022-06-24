import Solana
import OpenAPIClient
import AnyCodable

public struct Kinetic {
    var networkingRouter: NetworkingRouter?
    var accountStorage: KeychainAccountStorage?
    var solana: Solana?
    var environment: String
    var index: Double
    let KIN_MINT = PublicKey(string: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX")
//    let KIN_MINT = PublicKey(string: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6")
    let SAMPLE_WALLET = PublicKey(string: "3rad7aFPdJS3CkYPSphtDAWCNB8BYpV2yc7o5ZjFQbDb")
    let MEMO_V1_PROGRAM_ID = PublicKey(string: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")
    let ASSOCIATED_TOKEN_PROGRAM_ID = PublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!

    public init(environment: String?, index: Double, endpoint: String?) {
        // TODO: add logging and Solana RPC config here
        self.environment = environment ?? "devnet"
        self.index = index
        networkingRouter = { switch self.environment {
        case "devnet":
            return NetworkingRouter(endpoint: .devnetSolana)
        case "testnet":
            return NetworkingRouter(endpoint: .testnetSolana)
        default:
            return NetworkingRouter(endpoint: .mainnetBetaSolana)
        } }()
        accountStorage = KeychainAccountStorage()
        solana = Solana(router: networkingRouter!)
        OpenAPIClientAPI.basePath = endpoint ?? "http://localhost:3000"
    }

    public func createAccount(account: Account, _ callback: @escaping ((String) -> Void)) {
        AppAPI.getAppConfig(environment: environment, index: index) { appConfig, e in
            guard let appConfig = appConfig else {
                if let e = e {
                    callback(String(describing: e))
                    return
                }
                callback("failed to get app config")
                return
            }
            let mintKey = PublicKey(string: appConfig.mint.publicKey)!
            let feePayer = PublicKey(string: appConfig.mint.feePayer)!
            TransactionAPI.getLatestBlockhash(environment: environment, index: index) { latestBlockhashResponse, e in
                guard let latestBlockhashResponse = latestBlockhashResponse
                else {
                    if let e = e {
                        callback(String(describing: e))
                        return
                    }
                    callback("failed to get blockhash")
                    return
                }

                // Get token account
                guard case let .success(associatedTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: account.publicKey, tokenMintAddress: mintKey)
                else {
                    callback("could not get token account")
                    return
                }

                let memo = try! KinBinaryMemo(typeId: KinBinaryMemo.TransferType.none.rawValue, appIdx: UInt16(index))
                let memoData = [UInt8](memo.encode().base64EncodedString().data(using: .utf8)!)
                let memoInstruction = TransactionInstruction(keys: [], programId: MEMO_V1_PROGRAM_ID!, data: memoData)

                // Create Account Instructions
                solana!.api.getMinimumBalanceForRentExemption(dataLength: AccountInfo.BUFFER_LENGTH) { res in
                    res.onSuccess { minimumBalance in
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
                        let serializeRes = transaction.serialize(requiredAllSignatures: false, verifySignatures: false)
                        switch serializeRes {
                        case .success(let serialized):
                            let createAccountRequest = CreateAccountRequest(environment: environment, index: index, mint: appConfig.mint.symbol, tx: serialized.bytes)
                            AccountAPI.createAccount(createAccountRequest: createAccountRequest) { appTransaction, e in
                                guard let appTransaction = appTransaction else {
                                    if let e = e {
                                        print(e)
                                        callback(String(describing: e))
                                        return
                                    }
                                    callback("create account failed")
                                    return
                                }
                                print("success")
                                print(appTransaction)
                                print(appTransaction.signature)
                                callback(String(describing: appTransaction))
                            }
                        case .failure(let e):
                            print("here")
                            callback(String(describing: e))
                        }
                    }
                    res.onFailure { e in
                        callback(String(describing: e))
                        return
                    }
                }


            }

        }
    }

    public func getAirdrop(publicKey: String, _ callback: @escaping ((String) -> Void)) {
        AppAPI.getAppConfig(environment: environment, index: index) { appConfig, e in
            guard let appConfig = appConfig else {
                if let e = e {
                    callback(String(describing: e))
                    return
                }
                callback("failed to get app config")
                return
            }
            AirdropAPI.requestAirdrop(requestAirdropRequest: RequestAirdropRequest(account: publicKey, amount: "100", environment: environment, index: index, mint: appConfig.mint.symbol)) { airdropResponse, e in
                if let e = e {
                    callback(e.localizedDescription)
                } else {
                    callback(String(describing: airdropResponse!))
                }
            }
        }
    }

    public func getAccountBalance(publicKey: String, _ callback: @escaping ((String) -> Void)) {
        AccountAPI.getBalance(environment: environment, index: index, accountId: publicKey) { balanceResponse, e in
            if let e = e {
                callback(e.localizedDescription)
            } else {
                callback(balanceResponse!.balance.description)
            }
        }
    }

    public func getAccountInfo(publicKey: String, _ callback: @escaping ((String) -> Void)) {
        AccountAPI.apiAccountFeatureControllerGetAccountInfo(environment: environment,  index: index, accountId: publicKey) { accountInfoResponse, e in
            if let e = e {
                callback(e.localizedDescription)
            } else {
                callback(String(describing: accountInfoResponse!))
            }
        }
    }

    public func getAccountHistory(publicKey: String, _ callback: @escaping ((String) -> Void)) {
        AccountAPI.getHistory(environment: environment, index: index, accountId: publicKey) { historyResponses, e in
            if let e = e {
                callback(e.localizedDescription)
            } else {
                callback(String(describing: historyResponses!))
            }
        }
    }

    public func getTokenAccounts(publicKey: String, _ callback: @escaping ((String) -> Void)) {
        AccountAPI.tokenAccounts(environment: environment, index: index, accountId: publicKey) { tokenAccountsResponse, e in
            if let e = e {
                callback(e.localizedDescription)
            } else {
                callback(String(describing: tokenAccountsResponse!))
            }
        }
    }

    public func getAppConfig(_ callback: @escaping ((String) -> Void)) {
        AppAPI.getAppConfig(environment: environment, index: index) { appConfigResponse, e in
            if let e = e {
                callback(e.localizedDescription)
            } else {
                print(appConfigResponse!)
                callback(String(describing: appConfigResponse!))
            }
        }
    }

    public func makeTransfer(fromAccount: Account, toPublicKey: PublicKey, amount: Int, _ callback: @escaping ((String) -> Void)) {
        AppAPI.getAppConfig(environment: environment, index: index) { appConfig, e in
            guard let appConfig = appConfig else {
                if let e = e {
                    callback(String(describing: e))
                    return
                }
                callback("failed to get app config")
                return
            }
            let tokenProgramId = PublicKey(string: appConfig.mint.programId)!
            let mintKey = PublicKey(string: appConfig.mint.publicKey)!
            let feePayer = PublicKey(string: appConfig.mint.feePayer)!
            TransactionAPI.getLatestBlockhash(environment: environment, index: index) { latestBlockhashResponse, e in
                guard let latestBlockhashResponse = latestBlockhashResponse
                else {
                    if let e = e {
                        callback(String(describing: e))
                        return
                    }
                    callback("failed to get blockhash")
                    return
                }

                // Get token accounts
                guard
                    case let .success(fromTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: fromAccount.publicKey, tokenMintAddress: mintKey),
                    case let .success(toTokenAccount) = PublicKey.associatedTokenAddress(walletAddress: toPublicKey, tokenMintAddress: mintKey)
                else {
                    callback("could not get token accounts")
                    return
                }

                let memo = try! KinBinaryMemo(version: 1, typeId: KinBinaryMemo.TransferType.spend.rawValue, appIdx: UInt16(index))
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
                let serializeRes = transaction.serialize(requiredAllSignatures: false, verifySignatures: false)
                switch serializeRes {
                case .success(let serialized):
                    let makeTransferRequest = MakeTransferRequest(commitment: .confirmed, environment: environment, index: index, mint: appConfig.mint.symbol, lastValidBlockHeight: latestBlockhashResponse.lastValidBlockHeight, referenceId: nil, referenceType: nil, tx: serialized)
                    TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest) { makeTransferResponse, e in
                        guard let makeTransferResponse = makeTransferResponse else {
                            if let e = e {
                                print(e)
                                callback(String(describing: e))
                                return
                            }
                            callback("make transfer failed")
                            return
                        }
                        print("success")
                        callback(String(describing: makeTransferResponse))
                    }
                case .failure(let e):
                    callback(String(describing: e))
                }
            }
        }
    }

    // START: Pre-backend local functions
    public func createAccountLocal() -> Account? {
        let res = accountStorage!.account
        switch res {
            case .success(let account):
                print(account)
                return account
            case .failure(let e):
                print(e.localizedDescription)
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
                print(e.localizedDescription)
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
                        print(e.localizedDescription)
                    }
                }

            }
            res.onFailure { e in
                print(e)
            }
        }
    }

    public func makeAMemo() {
        let memo = try? KinBinaryMemo(typeId: KinBinaryMemo.TransferType.earn.rawValue, appIdx: UInt16(index))
        print(memo)
    }

    private func fixtureTest() {
        let fixtureAccount = Account(phrase: ["pill", "tomorrow", "foster", "begin", "walnut", "borrow", "virtual", "kick", "shift", "mutual", "shoe", "scatter"], network: .mainnetBeta, derivablePath: .default)
        print(fixtureAccount?.publicKey.base58EncodedString)
    }
}
