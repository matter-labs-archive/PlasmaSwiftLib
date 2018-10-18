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

class PlasmaSwiftLibTests: XCTestCase {

    func testInput() {
        let blockNumber: BigUInt = 10
        let txNumberInBlock: BigUInt = 1
        let outputNumberInTx: BigUInt = 1
        let amount: BigUInt = 500000000000000
        let input1 = TransactionInput(blockNumber: blockNumber, txNumberInBlock: txNumberInBlock, outputNumberInTx: outputNumberInTx, amount: amount)
        guard let data = input1?.data else {return}
        let input2 = TransactionInput(data: data)
        XCTAssert(blockNumber == input2?.blockNumber)
        XCTAssert(txNumberInBlock == input2?.txNumberInBlock)
        XCTAssert(outputNumberInTx == input2?.outputNumberInTx)
        XCTAssert(amount == input2?.amount)
    }
    
    func testOutput() {
        let outputNumberInTx: BigUInt = 10
        let receiverEthereumAddress: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
        let amount: BigUInt = 500000000000000
        let output1 = TransactionOutput(outputNumberInTx: outputNumberInTx, receiverEthereumAddress: receiverEthereumAddress, amount: amount)
        guard let data = output1?.data else {return}
        let output2 = TransactionOutput(data: data)
        XCTAssert(outputNumberInTx == output2?.outputNumberInTx)
        XCTAssert(receiverEthereumAddress == output2?.receiverEthereumAddress)
        XCTAssert(amount == output2?.amount)
    }
    
    func testTransaction() {
        let txType: BigUInt = 1
        
        let blockNumber1In: BigUInt = 10
        let txNumberInBlock1In: BigUInt = 1
        let outputNumberInTx1In: BigUInt = 1
        let amount1In: BigUInt = 500000000000000
        guard let input1 = TransactionInput(blockNumber: blockNumber1In,
                                      txNumberInBlock: txNumberInBlock1In,
                                      outputNumberInTx: outputNumberInTx1In,
                                      amount: amount1In) else {return}
        
        let blockNumber2In: BigUInt = 12
        let txNumberInBlock2In: BigUInt = 2
        let outputNumberInTx2In: BigUInt = 2
        let amount2In: BigUInt = 400000000000000
        guard let input2 = TransactionInput(blockNumber: blockNumber2In,
                                      txNumberInBlock: txNumberInBlock2In,
                                      outputNumberInTx: outputNumberInTx2In,
                                      amount: amount2In) else {return}
        
        let outputNumberInTx1Out: BigUInt = 1
        let receiverEthereumAddress1Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
        let amount1Out: BigUInt = 300000000000000
        guard let output1 = TransactionOutput(outputNumberInTx: outputNumberInTx1Out,
                                              receiverEthereumAddress: receiverEthereumAddress1Out,
                                              amount: amount1Out) else {return}
        
        let outputNumberInTx2Out: BigUInt = 4
        let receiverEthereumAddress2Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb5")!
        let amount2Out: BigUInt = 600000000000000
        guard let output2 = TransactionOutput(outputNumberInTx: outputNumberInTx2Out,
                                              receiverEthereumAddress: receiverEthereumAddress2Out,
                                              amount: amount2Out) else {return}
        
        let outputNumberInTx3Out: BigUInt = 2
        let receiverEthereumAddress3Out: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35ca5")!
        let amount3Out: BigUInt = 200000000000000
        guard let output3 = TransactionOutput(outputNumberInTx: outputNumberInTx3Out,
                                              receiverEthereumAddress: receiverEthereumAddress3Out,
                                              amount: amount3Out) else {return}
        
        
        let transaction1 = Transaction(txType: txType, inputs: [input1, input2], outputs: [output1, output2, output3])
        guard let data = transaction1?.data else {return}
        guard let transaction2 = Transaction(data: data) else {return}
        XCTAssert(txType == transaction2.txType)
        XCTAssert(input1.amount == transaction2.inputs[0].amount)
        XCTAssert(input1.blockNumber == transaction2.inputs[0].blockNumber)
        XCTAssert(input1.outputNumberInTx == transaction2.inputs[0].outputNumberInTx)
        XCTAssert(input1.txNumberInBlock == transaction2.inputs[0].txNumberInBlock)
        
        XCTAssert(input2.amount == transaction2.inputs[1].amount)
        XCTAssert(input2.blockNumber == transaction2.inputs[1].blockNumber)
        XCTAssert(input2.outputNumberInTx == transaction2.inputs[1].outputNumberInTx)
        XCTAssert(input2.txNumberInBlock == transaction2.inputs[1].txNumberInBlock)
        
        XCTAssert(output1.amount == transaction2.outputs[0].amount)
        XCTAssert(output1.outputNumberInTx == transaction2.outputs[0].outputNumberInTx)
        XCTAssert(output1.receiverEthereumAddress == transaction2.outputs[0].receiverEthereumAddress)
        
        XCTAssert(output2.amount == transaction2.outputs[1].amount)
        XCTAssert(output2.outputNumberInTx == transaction2.outputs[1].outputNumberInTx)
        XCTAssert(output2.receiverEthereumAddress == transaction2.outputs[1].receiverEthereumAddress)
        
        XCTAssert(output3.amount == transaction2.outputs[2].amount)
        XCTAssert(output3.outputNumberInTx == transaction2.outputs[2].outputNumberInTx)
        XCTAssert(output3.receiverEthereumAddress == transaction2.outputs[2].receiverEthereumAddress)
    }

}
