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
    func UTXOsToTransaction(utxos: [ListUTXOsModel], address: EthereumAddress, txType: Transaction.TransactionType) -> Transaction? {
        var mergedAmount: BigUInt = 0
        var inputs = [TransactionInput]()
        for i in utxos {
            guard let input = i.toTransactionInput() else {
                return nil
            }
            inputs.append(input)
            mergedAmount += input.amount
        }
        guard let output = TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: address, amount: mergedAmount) else {
            return nil
        }
        let outputs = [output]
        let transaction = Transaction(txType: .merge, inputs: inputs, outputs: outputs)
        return transaction
    }
    
    func formInputsForTransaction() -> [TransactionInput]? {
        let blockNumber1In: BigUInt = 10
        let txNumberInBlock1In: BigUInt = 1
        let outputNumberInTx1In: BigUInt = 3
        let amount1In: BigUInt = 5
        guard let input1 = TransactionInput(blockNumber: blockNumber1In,
                                            txNumberInBlock: txNumberInBlock1In,
                                            outputNumberInTx: outputNumberInTx1In,
                                            amount: amount1In) else {return nil}
        
        let blockNumber2In: BigUInt = 10
        let txNumberInBlock2In: BigUInt = 1
        let outputNumberInTx2In: BigUInt = 3
        let amount2In: BigUInt = 4
        guard let input2 = TransactionInput(blockNumber: blockNumber2In,
                                            txNumberInBlock: txNumberInBlock2In,
                                            outputNumberInTx: outputNumberInTx2In,
                                            amount: amount2In) else {return nil}
        return [input1, input2]
    }
    
    func formOutputsForTransaction() -> [TransactionOutput]? {
        let outputNumberInTx1Out: BigUInt = 3
        let receiverEthereumAddress1Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
        let amount1Out: BigUInt = 3
        guard let output1 = TransactionOutput(outputNumberInTx: outputNumberInTx1Out,
                                              receiverEthereumAddress: receiverEthereumAddress1Out,
                                              amount: amount1Out) else {return nil}
        
        let outputNumberInTx2Out: BigUInt = 3
        let receiverEthereumAddress2Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb5")!
        let amount2Out: BigUInt = 2
        guard let output2 = TransactionOutput(outputNumberInTx: outputNumberInTx2Out,
                                              receiverEthereumAddress: receiverEthereumAddress2Out,
                                              amount: amount2Out) else {return nil}
        
        let outputNumberInTx3Out: BigUInt = 3
        let receiverEthereumAddress3Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35ca5")!
        let amount3Out: BigUInt = 4
        guard let output3 = TransactionOutput(outputNumberInTx: outputNumberInTx3Out,
                                              receiverEthereumAddress: receiverEthereumAddress3Out,
                                              amount: amount3Out) else {return nil}
        return [output1, output2, output3]
    }
//    func formBlockHeaderForBlock() -> BlockHeader? {
//        let blockNumber: BigUInt = 10
//        let numberOfTxInBlock: BigUInt = 2
//        let parentHash: BigUInt = 1241252535353532
//        let merkleRootOfTheTxTree: BigUInt = 500000000
//        let v: BigUInt = 27
//        let r: BigUInt = 2
//        let s: BigUInt = 124124
//        let blockHeader = BlockHeader(blockNumber: blockNumber,
//                                      numberOfTxInBlock: numberOfTxInBlock,
//                                      parentHash: parentHash,
//                                      merkleRootOfTheTxTree: merkleRootOfTheTxTree,
//                                      v: v, r: r, s: s)
//        return blockHeader
//    }
//    
//    func formSignedTransactionsForBlock() -> [SignedTransaction]? {
//        let txType1: BigUInt = 1
//        guard let inputs = formInputsForTransaction() else {return nil}
//        guard let outputs = formOutputsForTransaction() else {return nil}
//        guard let transaction1 = Transaction(txType: txType1,
//                                             inputs: inputs,
//                                             outputs: outputs) else {return nil}
//        guard let signedTransaction1 = SignedTransaction(transaction: transaction1,
//                                                         v: 27,
//                                                         r: 2,
//                                                         s: 3) else {return nil}
//        
//        let txType2: BigUInt = 2
//        guard let transaction2 = Transaction(txType: txType2,
//                                             inputs: inputs,
//                                             outputs: outputs) else {return nil}
//        guard let signedTransaction2 = SignedTransaction(transaction: transaction2,
//                                                         v: 28,
//                                                         r: 4,
//                                                         s: 1) else {return nil}
//        
//        let txType3: BigUInt = 3
//        guard let transaction3 = Transaction(txType: txType3,
//                                             inputs: inputs,
//                                             outputs: outputs) else {return nil}
//        guard let signedTransaction3 = SignedTransaction(transaction: transaction3,
//                                                         v: 27,
//                                                         r: 1,
//                                                         s: 5) else {return nil}
//        
//        let txType4: BigUInt = 4
//        guard let transaction4 = Transaction(txType: txType4,
//                                             inputs: inputs,
//                                             outputs: outputs) else {return nil}
//        guard let signedTransaction4 = SignedTransaction(transaction: transaction4,
//                                                         v: 27,
//                                                         r: 1,
//                                                         s: 9) else {return nil}
//        
//        return [signedTransaction1,
//                signedTransaction2,
//                signedTransaction3,
//                signedTransaction4]
//    }

}
