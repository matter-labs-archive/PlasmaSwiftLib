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
    
    public var blockNumber: BigUInt
    public var numberOfTxInBlock: BigUInt
    public var parentHash: BigUInt
    public var merkleRootOfTheTxTree: BigUInt
    public var v: BigUInt
    public var r: BigUInt
    public var s: BigUInt
    public var data: Data
    
    public init?(blockNumber: BigUInt, numberOfTxInBlock: BigUInt, parentHash: BigUInt, merkleRootOfTheTxTree: BigUInt, v: BigUInt, r: BigUInt, s: BigUInt){
        guard blockNumber.bitWidth <= Constants.blockNumberMaxWidth else {return nil}
        guard numberOfTxInBlock.bitWidth <= Constants.numberOfTxInBlockMaxWidth else {return nil}
        guard parentHash.bitWidth <= Constants.parentHashMaxWidth else {return nil}
        guard merkleRootOfTheTxTree.bitWidth <= Constants.merkleRootOfTheTxTreeMaxWidth else {return nil}
        guard v.bitWidth <= Constants.vMaxWidth else {return nil}
        guard r.bitWidth <= Constants.rMaxWidth else {return nil}
        guard s.bitWidth <= Constants.sMaxWidth else {return nil}
        
        guard v == 27 || v == 28 else {return nil}
        
        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
        
        let dataArray = [blockNumber, numberOfTxInBlock, parentHash, merkleRootOfTheTxTree, v, r, s] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
