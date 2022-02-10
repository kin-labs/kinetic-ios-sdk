import Foundation
import Solana

public struct mogami {
    public private(set) var text = "Hello, World!"

    public init() {
    }

    public func createAccount() -> Account? {
        if let account = Account(network: .mainnetBeta) {
            print(account.publicKey)
            print(account.secretKey)
            print(account.phrase.joined(separator: " "))
            return account
//            addressText.text = account.publicKey.base58EncodedString
        }
        return nil
    }
}
