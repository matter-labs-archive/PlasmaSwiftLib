//
//  PlasmaSwiftLibTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt

@testable import PlasmaSwiftLib

class TransactionTests: XCTestCase {
    
    private let testHelpers = TestHelpers()

    func testInput() {
        let blockNumber: BigUInt = 10
        let txNumberInBlock: BigUInt = 1
        let outputNumberInTx: BigUInt = 1
        let amount: BigUInt = 500000000000000
        guard let input1 = TransactionInput(blockNumber: blockNumber, txNumberInBlock: txNumberInBlock, outputNumberInTx: outputNumberInTx, amount: amount) else {return}
        let data = input1.data
        guard let input2 = TransactionInput(data: data) else {return}
        print("input passed")
        XCTAssert(input1 == input2)
    }
    
    func testOutput() {
        let outputNumberInTx: BigUInt = 10
        let receiverEthereumAddress: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
        let amount: BigUInt = 500000000000000
        guard let output1 = TransactionOutput(outputNumberInTx: outputNumberInTx, receiverEthereumAddress: receiverEthereumAddress, amount: amount) else {return}
        let data = output1.data
        guard let output2 = TransactionOutput(data: data) else {return}
        print("output passed")
        XCTAssert(output1 == output2)
    }
    
    func testTransaction() {
        let txType: BigUInt = 1
        guard let inputs = testHelpers.formInputsForTransaction() else {return}
        guard let outputs = testHelpers.formOutputsForTransaction() else {return}
        
        guard let transaction1 = Transaction(txType: txType, inputs: inputs, outputs: outputs) else {return}
        let data = transaction1.data
        guard let transaction2 = Transaction(data: data) else {return}
        print("transaction passed")
        XCTAssert(transaction1 == transaction2)
    }
    
    func testSignedTransaction() {
        let txType: BigUInt = 1
        guard let inputs = testHelpers.formInputsForTransaction() else {return}
        guard let outputs = testHelpers.formOutputsForTransaction() else {return}
        guard let transaction = Transaction(txType: txType, inputs: inputs, outputs: outputs) else {return}
        let v: BigUInt = 27
        let r: BigUInt = 21424
        let s: BigUInt = 2424124
        guard let signedTransaction1 = SignedTransaction(transaction: transaction, v: v, r: r, s: s) else {return}
        let data = signedTransaction1.data
        guard let signedTransaction2 = SignedTransaction(data: data) else {return}
        print("signed transaction passed")
        XCTAssert(signedTransaction1 == signedTransaction2)
    }
    
    func testSignature() {
        let txType: BigUInt = 1
        guard let inputs = testHelpers.formInputsForTransaction() else {return}
        guard let outputs = testHelpers.formOutputsForTransaction() else {return}
        
        guard let transaction = Transaction(txType: txType, inputs: inputs, outputs: outputs) else {return}
        let signedTransaction = transaction.sign(privateKey: Data(hex: "1d9d18fc759fb16bd1541d6689e9cefe02917664c56eec83326d18d66e5f7cfd"))
        XCTAssertNotNil(signedTransaction)
    }
}
