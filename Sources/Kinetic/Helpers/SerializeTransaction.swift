//
//  SerializeTransaction.swift
//  
//
//  Created by Samuel Dowd on 10/6/22.
//

import Foundation

internal func serializeTransaction(_ transaction: SolanaTransaction) async throws -> String {
    var transaction = transaction
    let serializedRes: Data? = await withCheckedContinuation { continuation in
        let serializedRes = transaction.serialize(requiredAllSignatures: false, verifySignatures: false)
        switch serializedRes {
        case .success(let serialized):
            continuation.resume(returning: serialized)
        case .failure(let e):
            continuation.resume(returning: nil)
        }
    }
    guard let serialized = serializedRes else {
        throw KineticError.SerializationError
    }
    return serialized.base64EncodedString()
}
