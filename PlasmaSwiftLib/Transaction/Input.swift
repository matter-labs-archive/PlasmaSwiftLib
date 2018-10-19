//
//  Input.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class TransactionInput {
    
    private let helpers = TransactionHelpers()
    
    public var blockNumber: BigUInt
    public var txNumberInBlock: BigUInt
    public var outputNumberInTx: BigUInt
    public var amount: BigUInt
    public var data: Data
    public var transactionInput: [AnyObject]
    
    public init?(blockNumber: BigUInt, txNumberInBlock: BigUInt, outputNumberInTx: BigUInt, amount: BigUInt) {
        
        guard blockNumber.bitWidth <= Constants.blockNumberMaxWidth else {return nil}
        guard txNumberInBlock.bitWidth <= Constants.txNumberInBlockMaxWidth else {return nil}
        guard outputNumberInTx.bitWidth <= Constants.outputNumberInTxMaxWidth else {return nil}
        guard amount.bitWidth <= Constants.amountMaxWidth else {return nil}
        
        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
        
        let transactionInput = [blockNumber,
                                txNumberInBlock,
                                outputNumberInTx,
                                amount] as [AnyObject]
        self.transactionInput = transactionInput
        guard let data = RLP.encode(transactionInput) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let input = helpers.serializeInput(dataArray: dataArray) else {return nil}
        
        self.data = input.data
        self.blockNumber = input.blockNumber
        self.txNumberInBlock = input.txNumberInBlock
        self.outputNumberInTx = input.outputNumberInTx
        self.amount = input.amount
        self.transactionInput = [input.blockNumber,
                                 input.txNumberInBlock,
                                 input.outputNumberInTx,
                                 input.amount] as [AnyObject]
    }
}

extension TransactionInput: Equatable {
    public static func ==(lhs: TransactionInput, rhs: TransactionInput) -> Bool {
        return lhs.blockNumber == rhs.blockNumber &&
            lhs.txNumberInBlock == rhs.txNumberInBlock &&
            lhs.outputNumberInTx == rhs.outputNumberInTx &&
            lhs.amount == rhs.amount &&
            lhs.data == rhs.data
    }
}
