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
        let txType = Transaction.TransactionType.split
        let inputs = [TransactionInput]()
        let outputs = [TransactionOutput]()
        
        guard let transaction1 = Transaction(txType: txType, inputs: inputs, outputs: outputs) else {return}
        let data = transaction1.data
        guard let transaction2 = Transaction(data: data) else {return}
        print("transaction passed")
        XCTAssert(transaction1 == transaction2)
    }
    
    func testParseTransaction() {
        let data = Data(hex: "0xf8aef86901edec840000000184000000c800a0000000000000000000000000000000000000000000000000000000000000000af838f70094c5fdf4076b8f3a5357c5e395ab970b5b54098fefa0000000000000000000000000000000000000000000000000000000000000000a1ba07cb678cb684e53e92578d9982fafa3df9f9bd776b40e8101153a9174bd9c365aa00bb0580a5d5a86d140eebb894fa4deda8887629973f3c4c22347495d1867020f")
        let signedTX = SignedTransaction(data: data)
        XCTAssert(signedTX != nil)
    }
}
