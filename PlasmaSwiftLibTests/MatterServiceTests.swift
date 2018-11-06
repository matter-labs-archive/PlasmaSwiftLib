//
//  MatterServiceTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import secp256k1_swift
import EthereumAddress

@testable import PlasmaSwiftLib

class MatterServiceTests: XCTestCase {

    func testGetListUTXO() {
        let completedGetListExpectation = expectation(description: "Completed")
        MatterService().getListUTXOs(for: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                DispatchQueue.main.async {
                    for utxo in r {
                        print(utxo.value)
                    }
                    completedGetListExpectation.fulfill()
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedGetListExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testSendTransaction() {
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "36775b4bafc4d906c9035903785fcdb4f0e9e7b5d6f6f1a4b001bb5a4396c391")
        MatterService().getListUTXOs(for: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                XCTAssert(r.count > 0)
                let input = r[0].toTransactionInput()!
                let inputs = [input]
                let outputs = [TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, amount: input.amount)!]
                let transaction = Transaction(txType: .split, inputs: inputs, outputs: outputs)
                let signedTransaction = transaction!.sign(privateKey: privKey)
                XCTAssertEqual(EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, signedTransaction!.sender)
                MatterService().sendRawTX(transaction: signedTransaction!, onTestnet: true) { (result) in
                    switch result {
                    case .Success(let r):
                        DispatchQueue.main.async {
                            XCTAssert(r == true)
                            completedSendExpectation.fulfill()
                        }
                    case .Error(let error):
                        DispatchQueue.main.async {
                            XCTAssertNil(error)
                            completedSendExpectation.fulfill()
                        }
                    }
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testMergeUTXOs() {
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        MatterService().getListUTXOs(for: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                XCTAssert(r.count > 0)
                let input1 = r[0].toTransactionInput()!
                let input2 = r[1].toTransactionInput()!
                let inputs = [input1, input2]
                let mergedAmount = input1.amount + input2.amount
                let outputs = [TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, amount: mergedAmount)!]
                let transaction = Transaction(txType: .merge, inputs: inputs, outputs: outputs)
                let signedTransaction = transaction!.sign(privateKey: privKey)
                XCTAssertEqual(EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, signedTransaction!.sender)
                MatterService().sendRawTX(transaction: signedTransaction!, onTestnet: true) { (result) in
                    switch result {
                    case .Success(let r):
                        DispatchQueue.main.async {
                            XCTAssert(r == true)
                            completedSendExpectation.fulfill()
                        }
                    case .Error(let error):
                        DispatchQueue.main.async {
                            XCTAssertNil(error)
                            completedSendExpectation.fulfill()
                        }
                    }
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }
}
