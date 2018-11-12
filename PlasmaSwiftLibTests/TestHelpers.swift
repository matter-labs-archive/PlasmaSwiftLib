//
//  TestHelpers.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import EthereumAddress

@testable import PlasmaSwiftLib

class TestHelpers: XCTestCase {
    func UTXOsToTransaction(utxos: [PlasmaUTXOs], address: EthereumAddress, txType: Transaction.TransactionType) throws -> Transaction {
        var mergedAmount: BigUInt = 0
        var inputs = [TransactionInput]()
        for i in utxos {
            let input = try i.toTransactionInput()
            inputs.append(input)
            mergedAmount += input.amount
        }
        let output = try TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: address, amount: mergedAmount)
        let outputs = [output]
        let transaction = try Transaction(txType: .merge, inputs: inputs, outputs: outputs)
        return transaction
    }
    
    func formInputsForTransaction() throws -> [TransactionInput] {
        let blockNumber1In: BigUInt = 10
        let txNumberInBlock1In: BigUInt = 1
        let outputNumberInTx1In: BigUInt = 3
        let amount1In: BigUInt = 5
        let input1 = try TransactionInput(blockNumber: blockNumber1In,
                                            txNumberInBlock: txNumberInBlock1In,
                                            outputNumberInTx: outputNumberInTx1In,
                                            amount: amount1In)
        
        let blockNumber2In: BigUInt = 10
        let txNumberInBlock2In: BigUInt = 1
        let outputNumberInTx2In: BigUInt = 3
        let amount2In: BigUInt = 4
        let input2 = try TransactionInput(blockNumber: blockNumber2In,
                                            txNumberInBlock: txNumberInBlock2In,
                                            outputNumberInTx: outputNumberInTx2In,
                                            amount: amount2In)
        return [input1, input2]
    }
    
    func formOutputsForTransaction() throws -> [TransactionOutput] {
        let outputNumberInTx1Out: BigUInt = 3
        let receiverEthereumAddress1Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
        let amount1Out: BigUInt = 3
        let output1 = try TransactionOutput(outputNumberInTx: outputNumberInTx1Out,
                                              receiverEthereumAddress: receiverEthereumAddress1Out,
                                              amount: amount1Out)
        
        let outputNumberInTx2Out: BigUInt = 3
        let receiverEthereumAddress2Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb5")!
        let amount2Out: BigUInt = 2
        let output2 = try TransactionOutput(outputNumberInTx: outputNumberInTx2Out,
                                              receiverEthereumAddress: receiverEthereumAddress2Out,
                                              amount: amount2Out)
        
        let outputNumberInTx3Out: BigUInt = 3
        let receiverEthereumAddress3Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35ca5")!
        let amount3Out: BigUInt = 4
        let output3 = try TransactionOutput(outputNumberInTx: outputNumberInTx3Out,
                                              receiverEthereumAddress: receiverEthereumAddress3Out,
                                              amount: amount3Out)
        return [output1, output2, output3]
    }
    
    func formBlockHeaderForBlock() throws -> BlockHeader {
        let blockNumber: BigUInt = 9
        let numberOfTxInBlock: BigUInt = 1
        let parentHash: Data = Data(hex: "a48a6e55763e3904f50c3d51799e5a7fb3acfe14dd7ab0c735ae4d14b41704b5")
        let merkleRootOfTheTxTree: Data = Data(hex: "c49e9e7675e08f77878528a4f807f7bec53253054519d8cef4651736bd6e2fae")
        let v: BigUInt = 27
        let r: Data = Data(hex: "2d2c24ebe372c1a4c43cab65ec3808e2289d99019374839637097f5d20b7bc4f")
        let s: Data = Data(hex: "61f9d2e61d70da342bcd24d1f594c07f3d9471271659632151b7138378d1243c")
        let blockHeader = try BlockHeader(blockNumber: blockNumber,
                                              numberOfTxInBlock: numberOfTxInBlock,
                                              parentHash: parentHash,
                                              merkleRootOfTheTxTree: merkleRootOfTheTxTree,
                                              v: v, r: r, s: s)
        return blockHeader
    }

    func formSignedTransactionsForBlock() throws -> [SignedTransaction] {
        do {
            let inputs = try formInputsForTransaction()
            let outputs = try formOutputsForTransaction()
            let transaction1 = try Transaction(txType: .fund,
                                               inputs: inputs,
                                               outputs: outputs)
            let signedTransaction1 = try SignedTransaction(transaction: transaction1,
                                                       v: 27,
                                                       r: Data(hex: "2d2c24ebe372c1a4c43cab65ec3808e2289d99019374839637097f5d20b7bc4f"),
                                                       s: Data(hex: "61f9d2e61d70da342bcd24d1f594c07f3d9471271659632151b7138378d1243c"))
            
            let transaction2 = try Transaction(txType: .split,
                                               inputs: inputs,
                                               outputs: outputs)
            let signedTransaction2 = try SignedTransaction(transaction: transaction2,
                                                       v: 28,
                                                       r: Data(hex: "2d2c24ebe372c1a4c43cab65ec3808e2289d99019374839637097f5d20b7bc4f"),
                                                       s: Data(hex: "61f9d2e61d70da342bcd24d1f594c07f3d9471271659632151b7138378d1243c"))
            
            let transaction3 = try Transaction(txType: .merge,
                                               inputs: inputs,
                                               outputs: outputs)
            let signedTransaction3 = try SignedTransaction(transaction: transaction3,
                                                       v: 27,
                                                       r: Data(hex: "2d2c24ebe372c1a4c43cab65ec3808e2289d99019374839637097f5d20b7bc4f"),
                                                       s: Data(hex: "61f9d2e61d70da342bcd24d1f594c07f3d9471271659632151b7138378d1243c"))
            return [signedTransaction1,
                    signedTransaction2,
                    signedTransaction3]
        } catch {
            throw StructureErrors.wrongData
        }
        
    }
}
