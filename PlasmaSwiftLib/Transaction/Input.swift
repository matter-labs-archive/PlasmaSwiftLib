//
//  Input.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP

class TransactionInput {
    
    public var blockNumber: Array<UInt8>
    public var txNumberInBlock: Array<UInt8>
    public var outputNumberInTx: Array<UInt8>
    public var amount: Array<UInt8>
    public var data: Data
    
    public init?(blockNumber: Array<UInt8>, txNumberInBlock: Array<UInt8>, outputNumberInTx: Array<UInt8>, amount: Array<UInt8>) {
        guard blockNumber.count == Constants.blockNumberLength else {return nil}
        guard txNumberInBlock.count == Constants.txNumberInBlockLength else {return nil}
        guard outputNumberInTx.count == Constants.outputNumberInTxLength else {return nil}
        guard amount.count == Constants.amountLegth else {return nil}
        
        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
        
        let dataArray = [blockNumber, txNumberInBlock, outputNumberInTx, amount] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
