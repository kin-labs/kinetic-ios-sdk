//
//  GetTokenAddress.swift
//  
//
//  Created by Samuel Dowd on 10/7/22.
//

import Foundation

internal func getTokenAddress(ownerPublicKey: String, mintKey: String) -> String? {
    guard let owner = SolanaPublicKey(string: ownerPublicKey) else { return nil }
    guard let mint = SolanaPublicKey(string: mintKey) else { return nil }
    guard case let .success(ownerTokenAccount) = SolanaPublicKey.associatedTokenAddress(walletAddress: owner, tokenMintAddress: mint)
    else {
        return nil
    }
    return ownerTokenAccount.base58EncodedString
}
