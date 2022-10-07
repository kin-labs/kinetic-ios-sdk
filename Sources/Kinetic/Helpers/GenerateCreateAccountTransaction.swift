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
) async throws -> SolanaTransaction {
    // Create objects from Response
    let mintKey = SolanaPublicKey(string: mintPublicKey)!
    let feePayerKey = SolanaPublicKey(string: mintFeePayer)!
    let ownerPublicKey = owner.publicKey

    // Get AssociatedTokenAccount
    let ownerTokenAccount = try getAssociatedTokenAddress(ownerPublicKey: ownerPublicKey, mintKey: mintKey)

    var instructions: [TransactionInstruction] = []

    if (addMemo) {
        try instructions.append(generateKinMemoInstruction(appIndex: index, type: .none))
    }

    instructions.append(createAssociatedTokenAccountInstruction(feePayer: feePayerKey, ownerTokenAccount: ownerTokenAccount, ownerPublicKey: ownerPublicKey, mintKey: mintKey))

    var transaction = SolanaTransaction(signatures: [
        SolanaTransaction.Signature(signature: nil, publicKey: owner.publicKey)
    ], feePayer: feePayerKey, instructions: instructions, recentBlockhash: blockhash)
    transaction.partialSign(signers: [owner])

    return transaction
}
