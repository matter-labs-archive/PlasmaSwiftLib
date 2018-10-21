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
    public var block: [AnyObject]
    
    public init?(blockHeader: BlockHeader, signedTransactions: [SignedTransaction]){
        
        self.blockHeader = blockHeader
        self.signedTransactions = signedTransactions
        
        let blockHeaderData = blockHelpers.blockHeaderToAnyObjectArray(blockHeader: blockHeader)
        let signedTransactionsData = transactionHelpers.signedTransactionsToAnyObjectArray(signedTransactions: signedTransactions)
        
        let block = [blockHeaderData, signedTransactionsData] as [AnyObject]
        self.block = block
        guard let data = RLP.encode(block) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let block = blockHelpers.serializeBlock(dataArray: dataArray) else {return nil}
        
        self.data = data
        self.blockHeader = block.blockHeader
        self.signedTransactions = block.signedTransactions
        self.block = [block.blockHeader, block.signedTransactions] as [AnyObject]
    }
}

extension Block: Equatable {
    public static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.blockHeader == rhs.blockHeader &&
            lhs.signedTransactions == rhs.signedTransactions
        
    }
}
