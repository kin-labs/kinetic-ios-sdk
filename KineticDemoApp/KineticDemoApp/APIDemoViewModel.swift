//
//  APIDemoViewModel.swift
//  KineticDemoApp
//
//  Created by Samuel Dowd on 9/17/22.
//

import Foundation
import Kinetic

@MainActor final class APIDemoViewModel: ObservableObject {
    var kinetic: Kinetic?
    var account: KineticAccount?
    var testPublicKey = PublicKey(string: "BobQoPqWy5cpFioy1dMTYqNH9WpC39mkAEDJWXECoJ9y")!
    
    @Published var getAppConfigResponse: String = ""
    @Published var getBalanceResponse: String = ""
    @Published var getTokenAccountsResponse: String = ""
    @Published var getAccountHistoryResponse: String = ""
    @Published var getAirdropResponse: String = ""
    @Published var createAccountResponse: String = ""
    @Published var makeTransferResponse: String = ""

    func setupSDK() async {
        do {
            kinetic = try await KineticBuilder()
                .setEndpoint("https://staging.kinetic.host")
                .setEnvironment("devnet")
                .setIndex(1)
                .build()
            account = kinetic!.getLocalAccount() ?? kinetic!.createLocalAccount()
        } catch {
            print(error.localizedDescription)
        }
    }

    func getAppConfig() async {
        do {
            guard let kinetic = kinetic else {
                getAppConfigResponse = "Kinetic SDK not initialized"
                return
            }
            let appConfig = try await kinetic.getAppConfig()
            getAppConfigResponse = String(describing: appConfig)
        } catch {
            getAppConfigResponse = error.localizedDescription
        }
    }

    func getBalance() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getBalanceResponse = "Kinetic SDK not initialized"
                return
            }
            let balance = try await kinetic.getAccountBalance(publicKey: account.publicKey)
            getBalanceResponse = String(describing: balance)
        } catch {
            getBalanceResponse = error.localizedDescription
        }
    }

    func getTokenAccounts() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getTokenAccountsResponse = "Kinetic SDK not initialized"
                return
            }
            let tokenAccounts = try await kinetic.getTokenAccounts(publicKey: account.publicKey)
            getTokenAccountsResponse = String(describing: tokenAccounts)
        } catch {
            getTokenAccountsResponse = error.localizedDescription
        }
    }

    func getAccountHistory() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getAccountHistoryResponse = "Kinetic SDK not initialized"
                return
            }
            let accountHistory = try await kinetic.getAccountHistory(publicKey: account.publicKey)
            getAccountHistoryResponse = String(describing: accountHistory)
        } catch {
            getAccountHistoryResponse = error.localizedDescription
        }
    }

    func getAirdrop() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                getAirdropResponse = "Kinetic SDK not initialized"
                return
            }
            let airdrop = try await kinetic.getAirdrop(publicKey: account.publicKey.base58, amount: 100)
            getAirdropResponse = String(describing: airdrop)
        } catch {
            getAirdropResponse = error.localizedDescription
        }
    }

    func createAccount() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                createAccountResponse = "Kinetic SDK not initialized"
                return
            }
            let accountTx = try await kinetic.createAccount(account: account)
            createAccountResponse = String(describing: accountTx)
        } catch {
            createAccountResponse = error.localizedDescription
        }
    }

    func makeTransfer() async {
        do {
            guard let kinetic = kinetic, let account = account else {
                makeTransferResponse = "Kinetic SDK not initialized"
                return
            }
            let transferTx = try await kinetic.makeTransfer(fromAccount: account, toPublicKey: testPublicKey, amount: 1)
            makeTransferResponse = String(describing: transferTx)
        } catch {
            makeTransferResponse = error.localizedDescription
        }
    }
}
