//
//  ViewController.swift
//  Mogami iOS
//
//  Created by Samuel Dowd on 1/25/22.
//

import UIKit
import Mogami

class ViewController: UIViewController {

    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var solBalanceText: UILabel!
    @IBOutlet weak var kinBalanceText: UILabel!

    var mogami = Mogami()

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        if let account = mogami.createAccount() {
            print(account.publicKey)
            print(account.secretKey)
            print(account.phrase.joined(separator: " "))
            addressText.text = account.publicKey.base58EncodedString
        }
    }

    @IBAction func airdropButtonPressed(_ sender: Any) {
    }

    @IBAction func getBalancePressed(_ sender: Any) {
        mogami.getSOLBalance() { SOLBalance in
            DispatchQueue.main.async {
                self.solBalanceText.text = "\(SOLBalance ?? 0)"
            }
        }
        mogami.getSPLTokenBalance(token: "KIN") { SPLBalance in
            DispatchQueue.main.async {
                self.kinBalanceText.text = "\(SPLBalance ?? 0)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
