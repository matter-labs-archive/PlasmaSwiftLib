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
    
    private let blockHelpers = BlockHelpers()
    private let transactionHelpers = TransactionHelpers()
    
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
    
//    public init?(data: Data) {
//        
//        guard let item = RLP.decode(data) else {return nil}
//        guard let dataArray = item[0] else {return nil}
//        
//        guard let blockHeaderData = dataArray[0] else {return nil}
//        guard let signedTransactionsData = dataArray[1] else {return nil}
//        
//        guard let blockHeader = blockHelpers.serializeBlockHeader(dataArray: blockHeaderData) else {return}
//        let transactionsCount = blockHeader.numberOfTxInBlock
//        let convenienceCount = Int(transactionsCount/2)
//        for i in -convenienceCount ..< convenienceCount {
//            if let signedTransactionData = signedTransactionsData[i + convenienceCount] {
//                let signedTransaction = transactionHelpers.serializeSignedTransaction(signedTransactionData)
//            }
//        }
//        
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
