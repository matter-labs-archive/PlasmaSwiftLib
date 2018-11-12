//
//  OutputsManagement.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 23.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

public extension Transaction {
    public func mergeOutputs(untilMaxAmount: BigUInt) throws -> Transaction {
        let receiverAddress = self.outputs[0].receiverEthereumAddress

        var sortedOutputs: [TransactionOutput] = self.outputs.sorted { $0.amount <= $1.amount }

        var mergedAmount: BigUInt = 0
        var mergedCount: BigUInt = 0

        for output in sortedOutputs {
            let currentOutputAmount = output.amount
            if currentOutputAmount <= (untilMaxAmount - mergedAmount) {
                mergedCount += 1
                mergedAmount += currentOutputAmount
            } else {
                break
            }
        }

        guard mergedCount > 1 else {throw StructureErrors.wrongDataCount}

        sortedOutputs.removeFirst(Int(mergedCount))

        var newOutputsArray: [TransactionOutput] = []
        var index: BigUInt = 0
        for output in sortedOutputs {
            guard let fixedOutput = try? TransactionOutput(outputNumberInTx: index,
                                                      receiverEthereumAddress: receiverAddress,
                                                      amount: output.amount) else {throw StructureErrors.wrongData}
            newOutputsArray.append(fixedOutput)
            index += 1
        }
        guard let mergedOutput = try? TransactionOutput(outputNumberInTx: index,
                                                   receiverEthereumAddress: receiverAddress,
                                                   amount: mergedAmount) else {throw StructureErrors.wrongData}
        newOutputsArray.append(mergedOutput)

        guard let fixedTx = try? Transaction(txType: self.txType,
                                        inputs: self.inputs,
                                        outputs: newOutputsArray) else {throw StructureErrors.wrongData}

        return fixedTx
    }

    public func mergeOutputs(forMaxNumber: BigUInt) throws -> Transaction {
        let outputsCount = BigUInt(self.outputs.count)
        print(forMaxNumber)
        print(outputsCount)
        guard forMaxNumber < outputsCount && forMaxNumber != 0 else {throw StructureErrors.wrongDataCount}
        let outputsCountToMerge: BigUInt = outputsCount - forMaxNumber + 1
        let receiverAddress = self.outputs[0].receiverEthereumAddress

        var sortedOutputs: [TransactionOutput] = self.outputs.sorted { $0.amount <= $1.amount }

        var mergedAmount: BigUInt = 0
        var mergedCount: BigUInt = 0

        for output in sortedOutputs {
            let currentOutputAmount = output.amount
            if mergedCount < outputsCountToMerge {
                mergedCount += 1
                mergedAmount += currentOutputAmount
            } else {
                break
            }
        }

        guard mergedCount == outputsCountToMerge else {throw StructureErrors.wrongDataCount}

        sortedOutputs.removeFirst(Int(mergedCount))

        var newOutputsArray: [TransactionOutput] = []
        var index: BigUInt = 0
        for output in sortedOutputs {
            guard let fixedOutput = try? TransactionOutput(outputNumberInTx: index,
                                                      receiverEthereumAddress: receiverAddress,
                                                      amount: output.amount) else {throw StructureErrors.wrongData}
            newOutputsArray.append(fixedOutput)
            index += 1
        }
        guard let mergedOutput = try? TransactionOutput(outputNumberInTx: index,
                                                   receiverEthereumAddress: receiverAddress,
                                                   amount: mergedAmount) else {throw StructureErrors.wrongData}
        newOutputsArray.append(mergedOutput)

        guard let fixedTx = try? Transaction(txType: self.txType,
                                        inputs: self.inputs,
                                        outputs: newOutputsArray) else {throw StructureErrors.wrongData}

        return fixedTx
    }

}
