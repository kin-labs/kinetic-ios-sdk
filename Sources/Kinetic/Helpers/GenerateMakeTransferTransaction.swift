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
    destinationTokenAccount: String,
    index: Int,
    mintDecimals: Int,
    mintFeePayer: String,
    mintPublicKey: String,
    owner: Account,
    ownerTokenAccount: String,
    senderCreate: Bool = false,
    type: KineticKinMemo.TransactionType
) throws -> SolanaTransaction {
    // Create objects from Response
    guard let destinationPublicKey = SolanaPublicKey(string: destination) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    guard let destinationTokenAccountPublicKey = SolanaPublicKey(string: destinationTokenAccount) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    guard let feePayerKey = SolanaPublicKey(string: mintFeePayer) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    guard let mintKey = SolanaPublicKey(string: mintPublicKey) else {
        throw KineticError.InvalidPublicKeyStringError
    }
    let ownerPublicKey = owner.publicKey
    guard let ownerTokenAccountPublicKey = SolanaPublicKey(string: ownerTokenAccount) else {
        throw KineticError.InvalidPublicKeyStringError
    }

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
                ownerTokenAccount: destinationTokenAccountPublicKey,
                ownerPublicKey: destinationPublicKey,
                mintKey: mintKey
            )
        )
    }

    guard let amountNum = UInt64(amount) else {
        throw KineticError.InvalidAmountError
    }

    instructions.append(
        TokenProgram.transferCheckedInstruction(
            programId: SolanaPublicKey.tokenProgramId,
            source: ownerTokenAccountPublicKey,
            mint: mintKey,
            destination: destinationTokenAccountPublicKey,
            owner: ownerPublicKey,
            multiSigners: [],
            amount: amountNum,
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
