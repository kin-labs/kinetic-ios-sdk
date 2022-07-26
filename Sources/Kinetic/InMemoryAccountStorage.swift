//
//  InMemoryAccountStorage.swift
//  
//
//  Created by Samuel Dowd on 2/10/22.
//

import Foundation
import Solana

class InMemoryAccountStorage: SolanaAccountStorage {

    private var _account: Account?
    func save(_ account: Account) -> Result<Void, Error> {
        _account = account
        return .success(())
    }
    var account: Result<Account, Error> {
        return .success(_account!)

        // TODO: swap back to below. "Cannot find 'SolanaError' in scope"
        // Might be a version thing? That should be the only difference

//        if let account = _account {
//            return .success(account)
//        }
//        return .failure(SolanaError.unauthorized)
    }
    func clear() -> Result<Void, Error> {
        _account = nil
        return .success(())
    }
}
