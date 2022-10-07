//
//  GetAssociatedTokenAddress.swift
//  
//
//  Created by Samuel Dowd on 10/7/22.
//

import Foundation

internal func getAssociatedTokenAddress(ownerPublicKey: SolanaPublicKey, mintKey: SolanaPublicKey) throws -> SolanaPublicKey {
    guard case let .success(ownerTokenAccount) = SolanaPublicKey.associatedTokenAddress(walletAddress: ownerPublicKey, tokenMintAddress: mintKey)
    else {
        throw KineticError.GenerateTokenAccountError
    }
    return ownerTokenAccount
}
