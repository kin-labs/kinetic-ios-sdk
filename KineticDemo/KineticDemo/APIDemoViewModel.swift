//
//  APIDemoViewModel.swift
//  KineticDemoApp
//
//  Created by Samuel Dowd on 9/17/22.
//

import Foundation
import Kinetic

@MainActor final class APIDemoViewModel: ObservableObject {
    var kinetic: KineticSdk?
    var storage: BasicAccountStorage?
    var account: Keypair?
    var logsListener: Any?
    var testPublicKey = "BobQoPqWy5cpFioy1dMTYqNH9WpC39mkAEDJWXECoJ9y"
    
    @Published var getAppConfigResponse: String = ""
    @Published var getBalanceResponse: String = ""
    @Published var getTokenAccountsResponse: String = ""
    @Published var getAccountHistoryResponse: String = ""
    @Published var getAirdropResponse: String = ""
    @Published var createAccountResponse: String = ""
    @Published var makeTransferResponse: String = ""
    @Published var closeAccountResponse: String = ""

    func setupSDK() async {
        do {
            logsListener = KineticSdk.logger.sink { (level, log) in
                NSLog(log)
            }
            kinetic = try await KineticSdk.setup(
                KineticSdkConfig(
                    endpoint: "https://sandbox.kinetic.host",
                    environment: "devnet",
                    index: 1
                )
            )
            var storageDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            storageDirectory.appendPathComponent("kinetic_storage")
            storage = BasicAccountStorage(directory: storageDirectory)
            account = storage!.getLocalKeypair() ?? storage!.createLocalKeypair()!
        } catch {
            print(error)
        }
    }

    func getAppConfig() async {
        do {
            guard var kinetic = kinetic else {
                getAppConfigResponse = "Kinetic SDK not initialized"
                return
            }
            let appConfig = try await kinetic.initialize()
            getAppConfigResponse = String(describing: appConfig)
        } catch {
            getAppConfigResponse = String(describing: error)
        }
    }

    func getBalance() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getBalanceResponse = "Kinetic SDK not initialized"
                return
            }
            let balance = try await kinetic.getBalance(account: account.publicKey)
            getBalanceResponse = String(describing: balance)
        } catch {
            getBalanceResponse = String(describing: error)
        }
    }

    func getTokenAccounts() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getTokenAccountsResponse = "Kinetic SDK not initialized"
                return
            }
            let tokenAccounts = try await kinetic.getTokenAccounts(account: account.publicKey)
            getTokenAccountsResponse = String(describing: tokenAccounts)
        } catch {
            getTokenAccountsResponse = String(describing: error)
        }
    }

    func getAccountHistory() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getAccountHistoryResponse = "Kinetic SDK not initialized"
                return
            }
            let accountHistory = try await kinetic.getHistory(account: account.publicKey)
            getAccountHistoryResponse = String(describing: accountHistory)
        } catch {
            getAccountHistoryResponse = String(describing: error)
        }
    }

    func getAirdrop() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getAirdropResponse = "Kinetic SDK not initialized"
                return
            }
            let airdrop = try await kinetic.requestAirdrop(account: account.publicKey)
            getAirdropResponse = String(describing: airdrop)
        } catch {
            print(error)
            getAirdropResponse = String(describing: error)
        }
    }

    func createAccount() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                createAccountResponse = "Kinetic SDK not initialized"
                return
            }
            let accountTx = try await kinetic.createAccount(owner: account)
            createAccountResponse = String(describing: accountTx)
        } catch {
            createAccountResponse = String(describing: error)
        }
    }

    func makeTransfer() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                makeTransferResponse = "Kinetic SDK not initialized"
                return
            }
            let transferTx = try await kinetic.makeTransfer(amount: "1", destination: testPublicKey, owner: account)
            makeTransferResponse = String(describing: transferTx)
        } catch {
            makeTransferResponse = String(describing: error)
        }
    }

    func closeAccount() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                makeTransferResponse = "Kinetic SDK not initialized"
                return
            }
            let closeAccountTx = try await kinetic.closeAccount(account: account.publicKey)
            closeAccountResponse = String(describing: closeAccountTx)
        } catch {
            closeAccountResponse = String(describing: error)
        }
    }
}
