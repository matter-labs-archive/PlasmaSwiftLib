//
//  PlasmaSwiftLibTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import EthereumAddress

@testable import PlasmaSwiftLib

class TransactionTests: XCTestCase {
    
    let testHelpers = TestHelpers()

    func testInput() {
        do {
            let input1 = try TransactionInput(blockNumber: testHelpers.blockNumber, txNumberInBlock: testHelpers.txNumberInBlock, outputNumberInTx: testHelpers.outputNumberInTx, amount: testHelpers.depositAmount)
            let data = input1.data
            let input2 = try TransactionInput(data: data)
            XCTAssert(input1 == input2)
        } catch let error {
            XCTFail("Failed input test with error: \(error.localizedDescription)")
        }
    }

    func testOutput() {
        do {
            let output1 = try TransactionOutput(outputNumberInTx: testHelpers.outputNumberInTx, receiverEthereumAddress: testHelpers.toAddress, amount: testHelpers.depositAmount)
            let data = output1.data
            let output2 = try TransactionOutput(data: data)
            print("output passed")
            XCTAssert(output1 == output2)
        } catch let error {
            XCTFail("Failed output test with error: \(error.localizedDescription)")
        }
    }

    func testEmptyTransaction() {
        do {
            let txType = Transaction.TransactionType.split
            let inputs = [TransactionInput]()
            let outputs = [TransactionOutput]()
            let transaction1 = try Transaction(txType: txType, inputs: inputs, outputs: outputs)
            let data = transaction1.data
            let transaction2 = try Transaction(data: data)
            print("transaction empty passed")
            XCTAssert(transaction1 == transaction2)
        } catch let error {
            XCTFail("Failed empty tx test with error: \(error.localizedDescription)")
        }
    }

    func testNonEmptyTransaction() {
        do {
            let txType = Transaction.TransactionType.split

            let input = try TransactionInput(blockNumber: testHelpers.blockNumber, txNumberInBlock: testHelpers.txNumberInBlock, outputNumberInTx: testHelpers.outputNumberInTx, amount: testHelpers.depositAmount)
            let output = try TransactionOutput(outputNumberInTx: testHelpers.outputNumberInTx, receiverEthereumAddress: testHelpers.toAddress, amount: testHelpers.depositAmount)

            let inputs = [input]
            let outputs = [output]

            let transaction1 = try Transaction(txType: txType, inputs: inputs, outputs: outputs)
            let data = transaction1.data
            let transaction2 = try Transaction(data: data)
            print("transaction passed")
            XCTAssert(transaction1 == transaction2)
        } catch let error {
            XCTFail("Failed non empty tx test with error: \(error.localizedDescription)")
        }
    }

    func testParseTransaction() {
        do {
            let data = Data(hex: "0xf8dcf89702f85aec8400000058840000000000a00000000000000000000000000000000000000000000000000023b46bf7fe2000ec840000005d840000000000a00000000000000000000000000000000000000000000000000000befe6f672000f838f70094832a630b949575b87c0e3c00f624f773d9b160f4a00000000000000000000000000000000000000000000000000024736a676540001ca037b2fdabbbe29d3a5f24ba99e22ae3136065ba0b4fb74e476639b4dbaaed321ba060eb7b276bad0c651e427b278250921e73b2f47c072151159c72c852c2481516")
            let signedTX = try SignedTransaction(data: data)
            for output in signedTX.transaction.outputs {
                print("output:")
                print(output.amount)
                print(output.outputNumberInTx)
                print(output.receiverEthereumAddress)
            }
            for input in signedTX.transaction.inputs {
                print("input:")
                print(input.amount)
                print(input.outputNumberInTx)
                print(input.blockNumber)
                print(input.txNumberInBlock)
            }
            print(signedTX.transaction.txType)
            XCTAssert(signedTX.data == data)
        } catch let error {
            XCTFail("Failed parse tx test with error: \(error.localizedDescription)")
        }
    }

    func testMergeOutputsForFixedAmount() {
        do {
            let inputs = try testHelpers.formInputsForTransaction()
            let outputs = try testHelpers.formOutputsForTransaction()
            let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs)
            let newTx = try tx.mergeOutputs(untilMaxAmount: 6)
            XCTAssert(newTx.outputs.last?.amount == 5)
        } catch let error {
            XCTFail("Failed merge outputs test with error: \(error.localizedDescription)")
        }
    }

    func testMergeOutputsForFixedNumber() {
        do {
            let inputs = try testHelpers.formInputsForTransaction()
            let outputs = try testHelpers.formOutputsForTransaction()
            let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs)
            let newTx = try tx.mergeOutputs(forMaxNumber: 2)
            print("merge output passed")
            XCTAssert(newTx.outputs.count == 2)
        } catch let error {
            XCTFail("Failed input test with error: \(error.localizedDescription)")
        }
    }
    
    func testEmptyTxForMerkleTree() {
        do {
            let parsedTx = try SignedTransaction(data: emptyTx)
            XCTAssert(parsedTx.data == emptyTx)
            XCTAssert(parsedTx.v == 0)
        } catch let error {
            XCTFail("Failed input test with error: \(error.localizedDescription)")
        }
    }
}
