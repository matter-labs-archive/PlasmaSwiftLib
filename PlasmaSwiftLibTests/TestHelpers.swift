//
//  TestHelpers.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt

@testable import PlasmaSwiftLib

class TestHelpers: XCTestCase {
    
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
