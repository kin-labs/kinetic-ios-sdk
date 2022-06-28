//
//  ViewController.swift
//  Kinetic iOS
//
//  Created by Samuel Dowd on 1/25/22.
//

import UIKit
import Kinetic
import Solana

class ViewController: UIViewController {

    @IBOutlet weak var createAccountResultLabel: UILabel!
    @IBOutlet weak var getAirdropResultLabel: UILabel!
    @IBOutlet weak var getAccountBalanceResultLabel: UILabel!
    @IBOutlet weak var getAccountHistoryResultLabel: UILabel!
    @IBOutlet weak var getTokenAccountsResultLabel: UILabel!
    @IBOutlet weak var getAppConfigResultLabel: UILabel!
    @IBOutlet weak var makeTransferResultLabel: UILabel!

    var kinetic = Kinetic(environment: "devnet", index: 1, endpoint: "http://localhost:3000")
    var localAccount: Account?
    var logsListener: Any?

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        if let account = kinetic.createAccountLocal() {
            localAccount = account
            Task {
                do {
                    let appTransaction = try await kinetic.createAccount(account: localAccount!)
                    self.createAccountResultLabel.text = String(describing: appTransaction)
                } catch {
                    self.createAccountResultLabel.text = error.localizedDescription
                }
            }
        }
    }

    @IBAction func airdropButtonPressed(_ sender: Any) {
        Task {
            do {
                let airdropResult = try await kinetic.getAirdrop(publicKey: localAccount!.publicKey.base58EncodedString)
                self.getAirdropResultLabel.text = airdropResult.signature
            } catch {
                self.getAirdropResultLabel.text = error.localizedDescription
            }
        }
    }

    @IBAction func getBalancePressed(_ sender: Any) {
        Task {
            do {
                let balanceResult = try await kinetic.getAccountBalance(publicKey: localAccount!.publicKey.base58EncodedString)
                self.getAccountBalanceResultLabel.text = String(describing: balanceResult)
            } catch {
                self.getAccountBalanceResultLabel.text = error.localizedDescription
            }
        }
//        kinetic.getSOLBalance() { SOLBalance in
//            DispatchQueue.main.async {
//                self.solBalanceText.text = "\(SOLBalance ?? 0)"
//            }
//        }
//        kinetic.getSPLTokenBalance(token: "KIN") { SPLBalance in
//            DispatchQueue.main.async {
//                self.kinBalanceText.text = "\(SPLBalance ?? 0)"
//            }
//        }
    }

    @IBAction func getAccountHistoryButtonPressed(_ sender: Any) {
        Task {
            do {
                let accountHistoryResult = try await kinetic.getAccountHistory(publicKey: localAccount!.publicKey.base58EncodedString)
                self.getAccountHistoryResultLabel.text = accountHistoryResult.description
            } catch {
                self.getAccountHistoryResultLabel.text = error.localizedDescription
            }
        }
    }

    @IBAction func getTokenAccountsButtonPressed(_ sender: Any) {
        Task {
            do {
                let tokenAccountsResult = try await kinetic.getTokenAccounts(publicKey: localAccount!.publicKey.base58EncodedString)
                self.getTokenAccountsResultLabel.text = tokenAccountsResult.description
            } catch {
                self.getTokenAccountsResultLabel.text = error.localizedDescription
            }
        }
    }

    @IBAction func getAppConfigButtonPressed(_ sender: Any) {
        Task {
            do {
                let appConfig = try await kinetic.getAppConfig()
                self.getAppConfigResultLabel.text = String(describing: appConfig)
            } catch {
                self.getAppConfigResultLabel.text = error.localizedDescription
            }
        }
    }
    
    @IBAction func makeTransferButtonPressed(_ sender: Any) {
        Task {
            if let appTransaction = try? await kinetic.makeTransfer(fromAccount: localAccount!, toPublicKey: PublicKey(string: "BobQoPqWy5cpFioy1dMTYqNH9WpC39mkAEDJWXECoJ9y")!, amount: 1) {
                self.makeTransferResultLabel.text = String(describing: appTransaction)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logsListener = kinetic.logPublisher.sink { (level, log) in
            NSLog(log)
        }

    }
}
