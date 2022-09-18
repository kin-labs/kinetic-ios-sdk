//
//  APIDemoView.swift
//  KineticDemoApp
//
//  Created by Samuel Dowd on 9/15/22.
//

import SwiftUI
import Kinetic

struct APIDemoView: View {
    @StateObject var viewModel = APIDemoViewModel()

    var body: some View {
        VStack {
            Text("Kinetic Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack {
                Button("GetAppConfig") {
                    Task {
                        await viewModel.getAppConfig()
                    }
                }
                Text(viewModel.getAppConfigResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("GetBalance") {
                    Task {
                        await viewModel.getBalance()
                    }
                }
                Text(viewModel.getBalanceResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("GetTokenAccounts") {
                    Task {
                        await viewModel.getTokenAccounts()
                    }
                }
                Text(viewModel.getTokenAccountsResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("GetAccountHistory") {
                    Task {
                        await viewModel.getAccountHistory()
                    }
                }
                Text(viewModel.getAccountHistoryResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("GetAirdrop") {
                    Task {
                        await viewModel.getAirdrop()
                    }
                }
                Text(viewModel.getAirdropResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("CreateAccount") {
                    Task {
                        await viewModel.createAccount()
                    }
                }
                Text(viewModel.createAccountResponse)
                    .font(.system(size: 8))
            }
            HStack {
                Button("MakeTransfer") {
                    Task {
                        await viewModel.makeTransfer()
                    }
                }
                Text(viewModel.makeTransferResponse)
                    .font(.system(size: 8))
            }
        }
        .task {
            await viewModel.setupSDK()
        }
        .padding()
    }
}

struct APIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        APIDemoView()
    }
}
