import Solana

public struct Mogami {
    public private(set) var text = "Hello, World!"
    var networkingRouter: NetworkingRouter?
    var accountStorage: InMemoryAccountStorage?
    var solana: Solana?
    let KIN_MINT = PublicKey(string: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6")
    let SAMPLE_WALLET = PublicKey(string: "3rad7aFPdJS3CkYPSphtDAWCNB8BYpV2yc7o5ZjFQbDb")

    public init() {
        networkingRouter = NetworkingRouter(endpoint: .mainnetBetaSolana)
        accountStorage = InMemoryAccountStorage()
        solana = Solana(router: networkingRouter!, accountStorage: accountStorage!)
    }

    public func createAccount() -> Account? {
        return Account(network: .mainnetBeta)
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

    private func fixtureTest() {
        let fixtureAccount = Account(phrase: ["pill", "tomorrow", "foster", "begin", "walnut", "borrow", "virtual", "kick", "shift", "mutual", "shoe", "scatter"], network: .mainnetBeta, derivablePath: .default)
        print(fixtureAccount?.publicKey.base58EncodedString)
    }
}
