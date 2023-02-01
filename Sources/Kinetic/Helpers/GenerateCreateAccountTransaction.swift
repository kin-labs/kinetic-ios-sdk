//
//  GenerateCreateAccountTransaction.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation
import Solana

internal func generateCreateAccountTransaction(
    addMemo: Bool,
    blockhash: String,
    index: Int,
    mintFeePayer: String,
    mintPublicKey: String,
    owner: Account
) throws -> SolanaTransaction {
    // Create objects from Response
    guard let mintKey = SolanaPublicKey(string: mintPublicKey) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    guard let feePayerKey = SolanaPublicKey(string: mintFeePayer) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    let ownerPublicKey = owner.publicKey

    // Get AssociatedTokenAccount
    guard let ownerTokenAccount = getTokenAddress(ownerPublicKey: ownerPublicKey.base58EncodedString, mintKey: mintPublicKey) else {
        throw KineticError.GenerateTokenAccountError
    }
    guard let ownerTokenAccountPublicKey = SolanaPublicKey(string: ownerTokenAccount) else {
        throw KineticError.InvalidPublicKeyStringError
    }

    var instructions: [TransactionInstruction] = []

    if (addMemo) {
        try instructions.append(generateKinMemoInstruction(appIndex: index, type: .none))
    }

    instructions.append(createAssociatedTokenAccountInstruction(
        feePayer: feePayerKey,
        ownerTokenAccount: ownerTokenAccountPublicKey,
        ownerPublicKey: ownerPublicKey,
        mintKey: mintKey
    ))

    instructions.append(createSetCloseAuthorityInstruction(
        account: ownerTokenAccountPublicKey,
        currentAuthority: ownerPublicKey,
        newAuthority: feePayerKey
    ))

    var transaction = SolanaTransaction(signatures: [
        SolanaTransaction.Signature(signature: nil, publicKey: owner.publicKey)
    ], feePayer: feePayerKey, instructions: instructions, recentBlockhash: blockhash)
    transaction.partialSign(signers: [owner])

    return transaction
}
