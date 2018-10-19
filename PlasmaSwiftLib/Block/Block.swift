//
//  Block.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class Block {
    
    public var blockHeader: BlockHeader
    public var signedTransactions: [SignedTransaction]
    public var data: Data
    
    public init?(blockHeader: BlockHeader, signedTransactions: [SignedTransaction]){
        
        self.blockHeader = blockHeader
        self.signedTransactions = signedTransactions
        
        let dataArray = [blockHeader, signedTransactions] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
//    
//    public init?(data: Data) {
//        
//        guard let item = RLP.decode(data) else {return nil}
//        guard let dataArray = item[0] else {return nil}
//        
//        guard let blockNumberData = dataArray[0]?.data else {return nil}
//        guard let txNumberInBlockData = dataArray[1]?.data else {return nil}
//        guard let outputNumberInTxData = dataArray[2]?.data else {return nil}
//        guard let amountData = dataArray[3]?.data else {return nil}
//        
//        let blockNumber = BigUInt(blockNumberData)
//        let txNumberInBlock = BigUInt(txNumberInBlockData)
//        let outputNumberInTx = BigUInt(outputNumberInTxData)
//        let amount = BigUInt(amountData)
//        
//        self.data = data
//        self.blockNumber = blockNumber
//        self.txNumberInBlock = txNumberInBlock
//        self.outputNumberInTx = outputNumberInTx
//        self.amount = amount
//        self.transactionInput = [blockNumber, txNumberInBlock, outputNumberInTx, amount] as [AnyObject]
//    }
}
