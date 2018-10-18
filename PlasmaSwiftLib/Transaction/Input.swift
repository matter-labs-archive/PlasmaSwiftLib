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
    
    public var blockNumber: UInt32
    public var txNumberInBlock: UInt32
    public var outputNumberInTx: UInt8
    public var amount: BigUInt
    public var data: Data
    
    public init?(blockNumber: UInt32, txNumberInBlock: UInt32, outputNumberInTx: UInt8, amount: BigUInt) {
        guard amount.bitWidth <= Constants.amountMaxWidth else {return nil}
        
        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
        
        let dataArray = [blockNumber, txNumberInBlock, outputNumberInTx, amount] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
