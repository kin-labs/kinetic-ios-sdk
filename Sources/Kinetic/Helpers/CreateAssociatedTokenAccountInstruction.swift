//
//  CreateAssociatedTokenAccountInstruction.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation
import Solana

internal func createAssociatedTokenAccountInstruction(feePayer: SolanaPublicKey, ownerTokenAccount: SolanaPublicKey, ownerPublicKey: SolanaPublicKey, mintKey: SolanaPublicKey) -> TransactionInstruction {
    let createAccountInstruction = TransactionInstruction(
        keys: [
            AccountMeta(publicKey: feePayer, isSigner: true, isWritable: true),
            AccountMeta(publicKey: ownerTokenAccount, isSigner: false, isWritable: true),
            AccountMeta(publicKey: ownerPublicKey, isSigner: true, isWritable: false),
            AccountMeta(publicKey: mintKey, isSigner: false, isWritable: false),
            AccountMeta(publicKey: SolanaPublicKey.systemProgramId, isSigner: false, isWritable: false),
            AccountMeta(publicKey: SolanaPublicKey.tokenProgramId, isSigner: false, isWritable: false),
            AccountMeta(publicKey: SolanaPublicKey.sysvarRent, isSigner: false, isWritable: false)
        ],
        programId: SolanaPublicKey.splAssociatedTokenAccountProgramId,
        data: []
    )
    return createAccountInstruction
}
