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
    @IBOutlet weak var getAccountInfoResultLabel: UILabel!
    @IBOutlet weak var getAccountHistoryResultLabel: UILabel!
    @IBOutlet weak var getTokenAccountsResultLabel: UILabel!
    @IBOutlet weak var getAppConfigResultLabel: UILabel!
    @IBOutlet weak var makeTransferResultLabel: UILabel!

    var kinetic = Kinetic()
    var localAccount: Account?

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        if let account = kinetic.createAccountLocal() {
            localAccount = account
            print(account.publicKey)
            print(account.secretKey)
            print(account.phrase.joined(separator: " "))
            kinetic.createAccount(account: localAccount!) { res in
                DispatchQueue.main.async {
                    self.createAccountResultLabel.text = res
                }
            }
        }
    }

    @IBAction func airdropButtonPressed(_ sender: Any) {
        kinetic.getAirdrop(publicKey: localAccount!.publicKey.base58EncodedString) { res in
            self.getAirdropResultLabel.text = res
        }
    }

    @IBAction func getBalancePressed(_ sender: Any) {
        kinetic.getAccountBalance(publicKey: localAccount!.publicKey.base58EncodedString) { res in
            self.getAccountBalanceResultLabel.text = res
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

    @IBAction func getAccountInfoButtonPressed(_ sender: Any) {
        kinetic.getAccountInfo(publicKey: localAccount!.publicKey.base58EncodedString) { res in
            self.getAccountInfoResultLabel.text = res
        }
    }

    @IBAction func getAccountHistoryButtonPressed(_ sender: Any) {
        kinetic.getAccountHistory(publicKey: localAccount!.publicKey.base58EncodedString) { res in
            self.getAccountHistoryResultLabel.text = res
        }
    }

    @IBAction func getTokenAccountsButtonPressed(_ sender: Any) {
        kinetic.getTokenAccounts(publicKey: localAccount!.publicKey.base58EncodedString) { res in
            self.getTokenAccountsResultLabel.text = res
        }
    }

    @IBAction func getAppConfigButtonPressed(_ sender: Any) {
        kinetic.getAppConfig() { res in
            self.getAppConfigResultLabel.text = res
        }
    }
    
    @IBAction func makeTransferButtonPressed(_ sender: Any) {
        kinetic.makeTransfer(fromAccount: localAccount!, toPublicKey: PublicKey(string: "BobQoPqWy5cpFioy1dMTYqNH9WpC39mkAEDJWXECoJ9y")!, amount: 1) { res in
            self.makeTransferResultLabel.text = res
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
