//
//  AddRemoveDecimals.swift
//  
//
//  Created by Samuel Dowd on 10/28/22.
//

import Foundation

public func addDecimals(amount: String, decimals: Int) throws -> Decimal {
    if let d = Decimal(string: amount) {
        return d * Decimal(pow(10, Double(decimals)))
    } else { throw KineticError.InvalidAmountError }
}

public func removeDecimals(amount: String, decimals: Int) throws -> Decimal {
    if let d = Decimal(string: amount) {
        return d / Decimal(pow(10, Double(decimals)))
    } else { throw KineticError.InvalidAmountError }
}
