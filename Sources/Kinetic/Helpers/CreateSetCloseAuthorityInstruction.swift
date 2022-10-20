//
//  CreateSetCloseAuthorityInstruction.swift
//  
//
//  Created by Samuel Dowd on 10/8/22.
//

import Foundation
import Solana

internal func createSetCloseAuthorityInstruction(
    account: SolanaPublicKey,
    currentAuthority: SolanaPublicKey,
    newAuthority: SolanaPublicKey
) -> TransactionInstruction {
    let keys = [
        AccountMeta(publicKey: account, isSigner: false, isWritable: true),
        AccountMeta(publicKey: currentAuthority, isSigner: true, isWritable: false)
    ]
    let SET_AUTHORITY_INSTRUCTION: UInt8 = 6
    let AUTHORITY_TYPE: UInt8 = 3
    let NEW_AUTHORITY_OPTION: UInt8 = 1

    var data: [UInt8] = [
        SET_AUTHORITY_INSTRUCTION,
        AUTHORITY_TYPE,
        NEW_AUTHORITY_OPTION
    ]
    data.append(contentsOf: newAuthority.bytes)

    let setCloseAuthorityInstruction = TransactionInstruction(keys: keys, programId: PublicKey.tokenProgramId, data: data)

    return setCloseAuthorityInstruction
}
