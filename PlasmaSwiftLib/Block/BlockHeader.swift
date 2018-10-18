//
//  BlockHeader.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class BlockHeader {
    
    public var blockNumber: UInt32
    public var numberOfTxInBlock: UInt32
    public var parentHash: BigUInt
    public var merkleRootOfTheTransactionsTree: BigUInt
    public var v: UInt8
    public var r: BigUInt
    public var s: BigUInt
    public var data: Data
    
    public init?(blockNumber: UInt32, numberOfTxInBlock: UInt32, parentHash: BigUInt, merkleRootOfTheTransactionsTree: BigUInt, v: UInt8, r: BigUInt, s: BigUInt){
        guard v == 27 || v == 28 else {return nil}
        
        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTransactionsTree = merkleRootOfTheTransactionsTree
        self.v = v
        self.r = r
        self.s = s
        
        let dataArray = [blockNumber, numberOfTxInBlock, parentHash, merkleRootOfTheTransactionsTree, v, r, s] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
