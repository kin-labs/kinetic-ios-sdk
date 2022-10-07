//
//  GenerateKinMemoInstruction.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation
import Solana

internal func generateKinMemoInstruction(appIndex: Int, type: KineticKinMemo.TransactionType) throws -> TransactionInstruction {
    let MEMO_V1_PROGRAM_ID = SolanaPublicKey(string: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")
    let memo = try KineticKinMemo(typeId: type.rawValue, appIdx: UInt16(appIndex))
    let memoData = [UInt8](memo.encode().base64EncodedString().data(using: .utf8)!)
    return TransactionInstruction(keys: [], programId: MEMO_V1_PROGRAM_ID!, data: memoData)
}
