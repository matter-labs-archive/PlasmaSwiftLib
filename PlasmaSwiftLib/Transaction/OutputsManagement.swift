//
//  OutputsManagement.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 23.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

extension Transaction {
    func mergeOutputs(until maxAmount: BigUInt) -> Transaction? {
        let receiverAddress = self.outputs[0].receiverEthereumAddress
        let numberOfOutputsBeforeMerge = self.outputs[0].outputNumberInTx
        
        var sortedOutputs: Array<TransactionOutput> = self.outputs.sorted { $0.amount <= $1.amount }
        
        var mergedAmount: BigUInt = 0
        var mergedCount: BigUInt = 0
        
        for output in sortedOutputs {
            let currentOutputAmount = output.amount
            if currentOutputAmount <= (maxAmount - mergedAmount) {
                mergedCount += 1
                mergedAmount += currentOutputAmount
            } else {
                break
            }
        }
        
        guard mergedCount > 1 else  { return nil }
        print(numberOfOutputsBeforeMerge)
        print(mergedCount)
        let newOutputsCount = numberOfOutputsBeforeMerge - mergedCount + 1
        guard let mergedOutput = TransactionOutput(outputNumberInTx: newOutputsCount, receiverEthereumAddress: receiverAddress, amount: mergedAmount) else {return nil}
        
        sortedOutputs.removeFirst(Int(mergedCount))
        
        var newOutputsArray: Array<TransactionOutput> = []
        for output in sortedOutputs {
            guard let fixedOutput = TransactionOutput(outputNumberInTx: newOutputsCount, receiverEthereumAddress: receiverAddress, amount: output.amount) else {return nil}
            newOutputsArray.append(fixedOutput)
        }
        newOutputsArray.append(mergedOutput)
        
        var newInputsArray: Array<TransactionInput> = []
        for input in self.inputs {
            guard let fixedInput = TransactionInput(blockNumber: input.blockNumber, txNumberInBlock: input.txNumberInBlock, outputNumberInTx: newOutputsCount, amount: input.amount) else {return nil}
            newInputsArray.append(fixedInput)
        }
        
        guard let fixedTx = Transaction(txType: self.txType, inputs: newInputsArray, outputs: newOutputsArray) else {return nil}
        
        return fixedTx
    }
}
