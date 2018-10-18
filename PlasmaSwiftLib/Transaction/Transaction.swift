//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class Transaction {
    
    public var txType: BigUInt
    public var inputs: Array<TransactionInput>
    public var outputs: Array<TransactionOutput>
    public var data: Data
    
    public init?(txType: BigUInt, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>){
        guard txType.bitWidth <= Constants.txTypeMaxWidth else {return nil}
        guard inputs.count <= Constants.inputsArrayMax else {return nil}
        guard outputs.count <= Constants.outputsArrayMax else {return nil}
        
        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
        
        let dataArray = [txType, inputs, outputs] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
