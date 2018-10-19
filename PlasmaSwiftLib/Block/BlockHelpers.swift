//
//  BlockHelpers.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class BlockHelpers {
    
    private let transactionHelpers = TransactionHelpers()
    
    func serializeBlockHeader(dataArray: RLP.RLPItem) -> BlockHeader? {
        guard let blockNumberData = dataArray[0]?.data else {return nil}
        guard let numberOfTxInBlockData = dataArray[1]?.data else {return nil}
        guard let parentHashData = dataArray[2]?.data else {return nil}
        guard let merkleRootOfTheTxTreeData = dataArray[3]?.data else {return nil}
        guard let vData = dataArray[4]?.data else {return nil}
        guard let rData = dataArray[5]?.data else {return nil}
        guard let sData = dataArray[6]?.data else {return nil}
        
        let blockNumber = BigUInt(blockNumberData)
        let numberOfTxInBlock = BigUInt(numberOfTxInBlockData)
        let parentHash = BigUInt(parentHashData)
        let merkleRootOfTheTxTree = BigUInt(merkleRootOfTheTxTreeData)
        let v = BigUInt(vData)
        let r = BigUInt(rData)
        let s = BigUInt(sData)
        
        let blockHeader = BlockHeader(blockNumber: blockNumber,
                                      numberOfTxInBlock: numberOfTxInBlock,
                                      parentHash: parentHash,
                                      merkleRootOfTheTxTree: merkleRootOfTheTxTree,
                                      v: v,
                                      r: r,
                                      s: s)
        return blockHeader
    }
    
    func serializeBlock(dataArray: RLP.RLPItem) -> Block? {
        guard let blockHeaderData = dataArray[0] else {return nil}
        guard let signedTransactionsData = dataArray[1] else {return nil}
        
        guard let blockHeader = serializeBlockHeader(dataArray: blockHeaderData) else {return nil}
        
        var signedTransactions: [SignedTransaction] = []
        let transactionsCount = signedTransactionsData.count ?? 0
        let convenienceCount = Int(transactionsCount/2)
        for i in -convenienceCount ..< convenienceCount {
            if let signedTransactionData = signedTransactionsData[i + convenienceCount] {
                if let signedTransaction = transactionHelpers.serializeSignedTransaction(signedTransactionData) {
                    signedTransactions.append(signedTransaction)
                }
            }
        }
        
        let block = Block(blockHeader: blockHeader, signedTransactions: signedTransactions)
        return block
    }
}
