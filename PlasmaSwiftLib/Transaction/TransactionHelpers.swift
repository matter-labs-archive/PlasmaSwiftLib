//
//  TransactionSerialization.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class TransactionHelpers {
    
    func serializeInput(dataArray: RLP.RLPItem) -> TransactionInput? {
        guard let blockNumberData = dataArray[0]?.data else {return nil}
        guard let txNumberInBlockData = dataArray[1]?.data else {return nil}
        guard let outputNumberInTxData = dataArray[2]?.data else {return nil}
        guard let amountData = dataArray[3]?.data else {return nil}
        
        let blockNumber = BigUInt(blockNumberData)
        let txNumberInBlock = BigUInt(txNumberInBlockData)
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        let amount = BigUInt(amountData)
        
        let input = TransactionInput(blockNumber: blockNumber,
                                     txNumberInBlock: txNumberInBlock,
                                     outputNumberInTx: outputNumberInTx,
                                     amount: amount)
        return input
    }
    
    func serializeOutput(dataArray: RLP.RLPItem) -> TransactionOutput? {
        guard let outputNumberInTxData = dataArray[0]?.data else {return nil}
        guard let receiverEthereumAddressData = dataArray[1]?.data else {return nil}
        guard let amountData = dataArray[2]?.data else {return nil}
        
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        guard let receiverEthereumAddress = EthereumAddress(receiverEthereumAddressData) else {return nil}
        let amount = BigUInt(amountData)
        
        let output = TransactionOutput(outputNumberInTx: outputNumberInTx,
                                       receiverEthereumAddress: receiverEthereumAddress,
                                       amount: amount)
        return output
    }
    
    func serializeTransaction(_ dataArray: RLP.RLPItem) -> Transaction? {
        guard let txTypeData = dataArray[0]?.data else {return nil}
        guard let inputsData = dataArray[1] else {return nil}
        guard let outputsData = dataArray[2] else {return nil}
        
        let txType = BigUInt(txTypeData)
        guard let inputs = getInputsFromInputsRLP(inputsData: inputsData) else {return nil}
        guard let outputs = getOutputsFromOutputsRLP(outputsData: outputsData) else {return nil}
        
        
        let transaction = Transaction(txType: txType,
                                      inputs: inputs,
                                      outputs: outputs)
        
        return transaction
    }
    
    func serializeSignedTransaction(_ dataArray: RLP.RLPItem) -> SignedTransaction? {
        guard let tranactionData = dataArray[0] else {return nil}
        guard let vData = dataArray[1]?.data else {return nil}
        guard let rData = dataArray[2]?.data else {return nil}
        guard let sData = dataArray[3]?.data else {return nil}
        
        guard let transaction = serializeTransaction(tranactionData) else {return nil}
        let v = BigUInt(vData)
        let r = BigUInt(rData)
        let s = BigUInt(sData)
        
        guard let signedTransaction = SignedTransaction(transaction: transaction,
                                                        v: v,
                                                        r: r,
                                                        s: s) else {return nil}
        
        return signedTransaction
    }
    
    func getInputsFromInputsRLP(inputsData: RLP.RLPItem) -> Array<TransactionInput>? {
        guard let inputData1 = inputsData[0] else {return nil}
        let inputData2 = inputsData[1]
        
        guard let transactionInput1 = serializeInput(dataArray: inputData1) else {return nil}
        
        var transactionInput2: TransactionInput?
        if let inputData2Confirmed = inputData2 {
            transactionInput2 = serializeInput(dataArray: inputData2Confirmed)
        }
        
        var inputs: Array<TransactionInput> = [transactionInput1]
        if transactionInput2 != nil {
            inputs.append(transactionInput2!)
        }
        
        return inputs
    }
    
    func getOutputsFromOutputsRLP(outputsData: RLP.RLPItem) -> Array<TransactionOutput>? {
        guard let outputData1 = outputsData[0] else {return nil}
        let outputData2 = outputsData[1]
        let outputData3 = outputsData[2]
        
        guard let transactionOutput1 = serializeOutput(dataArray: outputData1) else {return nil}
        
        var transactionOutput2: TransactionOutput?
        if let outputData2Confirmed = outputData2 {
            transactionOutput2 = serializeOutput(dataArray: outputData2Confirmed)
        }
        
        var transactionOutput3: TransactionOutput?
        if let outputData3Confirmed = outputData3 {
            transactionOutput3 = serializeOutput(dataArray: outputData3Confirmed)
        }
        
        var outputs: Array<TransactionOutput> = [transactionOutput1]
        if transactionOutput2 != nil {
            outputs.append(transactionOutput2!)
        }
        if transactionOutput3 != nil {
            outputs.append(transactionOutput3!)
        }
        
        return outputs
    }
    
    func inputsToAnyObjectArray(inputs: Array<TransactionInput>) -> [AnyObject] {
        var inputsData: [AnyObject] = []
        for input in inputs {
            inputsData.append(input.transactionInput as AnyObject)
        }
        return inputsData
    }
    
    func outputsToAnyObjectArray(outputs: Array<TransactionOutput>) -> [AnyObject] {
        var outputsData: [AnyObject] = []
        for output in outputs {
            outputsData.append(output.transactionOutput as AnyObject)
        }
        return outputsData
    }
    
    func transactionToAnyObject(transaction: Transaction) -> [AnyObject] {
        return transaction.transaction
    }
}
