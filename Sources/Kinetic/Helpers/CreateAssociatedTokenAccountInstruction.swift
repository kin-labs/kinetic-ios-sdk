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
            Account.Meta(publicKey: feePayer, isSigner: true, isWritable: true),
            Account.Meta(publicKey: ownerTokenAccount, isSigner: false, isWritable: true),
            Account.Meta(publicKey: ownerPublicKey, isSigner: true, isWritable: false),
            Account.Meta(publicKey: mintKey, isSigner: false, isWritable: false),
            Account.Meta(publicKey: SolanaPublicKey.systemProgramId, isSigner: false, isWritable: false),
            Account.Meta(publicKey: SolanaPublicKey.tokenProgramId, isSigner: false, isWritable: false),
            Account.Meta(publicKey: SolanaPublicKey.sysvarRent, isSigner: false, isWritable: false)
        ],
        programId: SolanaPublicKey.splAssociatedTokenAccountProgramId,
        data: []
    )
    return createAccountInstruction
}
