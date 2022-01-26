//
//  ViewController.swift
//  Mogami iOS
//
//  Created by Samuel Dowd on 1/25/22.
//

import UIKit
import Solana

class ViewController: UIViewController {

    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var solBalanceText: UILabel!
    @IBOutlet weak var kinBalanceText: UILabel!

    var networkingRouter: NetworkingRouter?
    var accountStorage: InMemoryAccountStorage?
    var solana: Solana?
    let KIN_MINT = PublicKey(string: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6")
    let SAMPLE_WALLET = PublicKey(string: "3rad7aFPdJS3CkYPSphtDAWCNB8BYpV2yc7o5ZjFQbDb")

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        if let account = Account(network: .mainnetBeta) {
            print(account.publicKey)
            print(account.secretKey)
            print(account.phrase.joined(separator: " "))
            addressText.text = account.publicKey.base58EncodedString
        }
    }

    @IBAction func airdropButtonPressed(_ sender: Any) {
    }
    
    @IBAction func getBalancePressed(_ sender: Any) {
        solana!.api.getBalance(account: SAMPLE_WALLET!.base58EncodedString) { res in
            res.onSuccess { balance in
                DispatchQueue.main.async {
                    self.solBalanceText.text = balance.formatted()
                }
            }
            res.onFailure { e in
                print(e.localizedDescription)
            }
        }
        solana!.api.getTokenAccountsByOwner(pubkey: SAMPLE_WALLET!.base58EncodedString, mint: KIN_MINT!.base58EncodedString) { (res: Result<[TokenAccount<AccountInfo>], Error>) in
            res.onSuccess { tokenAccounts in
                let tokenAccount = tokenAccounts[0] // Just grabbing one for now
                self.solana!.api.getTokenAccountBalance(pubkey: tokenAccount.pubkey) { res in
                    res.onSuccess { balance in
                        DispatchQueue.main.async {
                            self.kinBalanceText.text = balance.uiAmountString
                        }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        networkingRouter = NetworkingRouter(endpoint: .mainnetBetaSolana)
        accountStorage = InMemoryAccountStorage()
        solana = Solana(router: networkingRouter!, accountStorage: accountStorage!)
    }


}

class InMemoryAccountStorage: SolanaAccountStorage {

    private var _account: Account?
    func save(_ account: Account) -> Result<Void, Error> {
        _account = account
        return .success(())
    }
    var account: Result<Account, Error> {
        if let account = _account {
            return .success(account)
        }
        return .failure(SolanaError.unauthorized)
    }
    func clear() -> Result<Void, Error> {
        _account = nil
        return .success(())
    }
}
