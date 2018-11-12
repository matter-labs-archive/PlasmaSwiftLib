//
//  listUTXOs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

public final class PlasmaUTXOs {
    public var blockNumber: BigUInt
    public var transactionNumber: BigUInt
    public var outputNumber: BigUInt
    public var value: BigUInt

    public init(json: [String: Any]) throws {
        guard let blockNumber = json["blockNumber"] as? Int else {throw StructureErrors.wrongData}
        guard let transactionNumber = json["transactionNumber"] as? Int else {throw StructureErrors.wrongData}
        guard let outputNumber = json["outputNumber"] as? Int else {throw StructureErrors.wrongData}
        guard let value = json["value"] as? String else {throw StructureErrors.wrongData}

        guard let bigUIntValue = BigUInt(value) else {throw StructureErrors.wrongData}

        self.blockNumber = BigUInt(blockNumber)
        self.transactionNumber = BigUInt(transactionNumber)
        self.outputNumber = BigUInt(outputNumber)
        self.value = bigUIntValue
    }

    public func toTransactionInput() throws -> TransactionInput {
        return try TransactionInput(blockNumber: self.blockNumber, txNumberInBlock: self.transactionNumber, outputNumberInTx: self.outputNumber, amount: self.value)
    }
}

extension PlasmaUTXOs: Equatable {
    public static func ==(lhs: PlasmaUTXOs, rhs: PlasmaUTXOs) -> Bool {
        let equalUTXOs = lhs.blockNumber == rhs.blockNumber &&
            lhs.outputNumber == rhs.outputNumber &&
            lhs.transactionNumber == rhs.transactionNumber &&
            lhs.value == rhs.value
        return equalUTXOs
    }
}
