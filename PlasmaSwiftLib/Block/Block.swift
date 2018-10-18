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
}
