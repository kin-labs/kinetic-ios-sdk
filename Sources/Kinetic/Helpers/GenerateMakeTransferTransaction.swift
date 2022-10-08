//
//  GenerateMakeTransferTransaction.swift
//  
//
//  Created by Samuel Dowd on 10/7/22.
//

import Foundation
import Solana

internal func generateMakeTransferTransaction(
    addMemo: Bool,
    amount: String,
    blockhash: String,
    destination: String,
    index: Int,
    mintDecimals: Int,
    mintFeePayer: String,
    mintPublicKey: String,
    owner: Account,
    senderCreate: Bool = false,
    type: KineticKinMemo.TransactionType
) throws -> SolanaTransaction {
    // Create objects from Response
    let mintKey = SolanaPublicKey(string: mintPublicKey)!
    let feePayerKey = SolanaPublicKey(string: mintFeePayer)!
    let ownerPublicKey = owner.publicKey

    let ownerTokenAccount = try getAssociatedTokenAddress(ownerPublicKey: ownerPublicKey, mintKey: mintKey)
    let destinationTokenAccount = try getAssociatedTokenAddress(ownerPublicKey: SolanaPublicKey(string: destination)!, mintKey: mintKey)

    var instructions: [TransactionInstruction] = []

    if addMemo {
        try instructions.append(
            generateKinMemoInstruction(appIndex: index, type: type)
        )
    }

    if senderCreate {
        instructions.append(
            createAssociatedTokenAccountInstruction(
                feePayer: feePayerKey,
                ownerTokenAccount: destinationTokenAccount,
                ownerPublicKey: SolanaPublicKey(string: destination)!,
                mintKey: mintKey
            )
        )
    }

    instructions.append(
        TokenProgram.transferCheckedInstruction(
            programId: SolanaPublicKey.tokenProgramId,
            source: ownerTokenAccount,
            mint: mintKey,
            destination: destinationTokenAccount,
            owner: ownerPublicKey,
            multiSigners: [],
            amount: UInt64(amount)!,
            decimals: UInt8(mintDecimals)
        )
    )

    var transaction = SolanaTransaction(
        signatures: [SolanaTransaction.Signature(signature: nil, publicKey: ownerPublicKey)],
        feePayer: feePayerKey,
        instructions: instructions,
        recentBlockhash: blockhash
    )

    transaction.partialSign(signers: [owner])

    return transaction
}
