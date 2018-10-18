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
    public var transaction: [AnyObject]
    
    public init?(txType: BigUInt, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>){
        guard txType.bitWidth <= Constants.txTypeMaxWidth else {return nil}
        guard inputs.count <= Constants.inputsArrayMax else {return nil}
        guard outputs.count <= Constants.outputsArrayMax else {return nil}
        
        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
        
        var inputsData: [AnyObject] = []
        for input in inputs {
            let inputData = [input.blockNumber, input.txNumberInBlock, input.outputNumberInTx, input.amount] as [AnyObject]
            inputsData.append(inputData as AnyObject)
        }
        
        var outputsData: [AnyObject] = []
        for output in outputs {
            let outputData = [output.outputNumberInTx, output.receiverEthereumAddressInData, output.amount] as [AnyObject]
            outputsData.append(outputData as AnyObject)
        }
        
        let transaction = [txType, inputsData, outputsData] as [AnyObject]
        self.transaction = transaction
        guard let data = RLP.encode(transaction) else {return nil}
        self.data = data
    }
}
