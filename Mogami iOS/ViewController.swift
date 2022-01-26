//
//  ViewController.swift
//  Mogami iOS
//
//  Created by Samuel Dowd on 1/25/22.
//

import UIKit
import Solana

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let networkingRouter = NetworkingRouter(endpoint: .mainnetBetaSolana)
        let accountStorage = InMemoryAccountStorage()
        let solana = Solana(router: networkingRouter, accountStorage: accountStorage)

        if let account = Account(network: .mainnetBeta) {
            print(account.publicKey)
            print(account.secretKey)
            print(account.phrase.joined(separator: " "))
        }
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
