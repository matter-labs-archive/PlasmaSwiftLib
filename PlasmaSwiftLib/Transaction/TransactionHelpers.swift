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
        var inputs: Array<TransactionInput> = []
        guard let inputsCount = inputsData.count else {return nil}
        for i in 0..<inputsCount {
            if let transactionInputData = inputsData[i] {
                if let transactionInput = serializeInput(dataArray: transactionInputData) {
                    inputs.append(transactionInput)
                }
            }
        }
        
        return inputs
    }
    
    func getOutputsFromOutputsRLP(outputsData: RLP.RLPItem) -> Array<TransactionOutput>? {
        var outputs: Array<TransactionOutput> = []
        guard let outputsCount = outputsData.count else {return nil}
        for i in 0..<outputsCount {
            if let transactionOutputData = outputsData[i] {
                if let transactionOutput = serializeOutput(dataArray: transactionOutputData) {
                    outputs.append(transactionOutput)
                }
            }
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
    
    func signedTransactionsToAnyObjectArray(signedTransactions: [SignedTransaction]) -> [AnyObject] {
        var signedTransactionsData: [AnyObject] = []
        for tx in signedTransactions {
            signedTransactionsData.append(tx.signedTransaction as AnyObject)
        }
        return signedTransactionsData
    }
    
    func hashForSignature(data: Data) -> Data? {
        let hash = data.sha3(.keccak256)
        return hash
    }
}
