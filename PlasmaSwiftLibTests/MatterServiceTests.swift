//
//  MatterServiceTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt

@testable import PlasmaSwiftLib

class MatterServiceTests: XCTestCase {
    
    func testGetListUTXO() {
        let completedGetListExpectation = expectation(description: "Completed")
        serviceUTXO().getListUTXOs(for: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                DispatchQueue.main.async {
                    XCTAssertNotNil(r?.value)
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
        let value = BigUInt("10000000000000")!
        let inputs = [TransactionInput(blockNumber: 1, txNumberInBlock: 0, outputNumberInTx: 0, amount: value)]
        let outputs = [TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, amount: value)]
        let transaction = Transaction(txType: 1, inputs: inputs as! Array<TransactionInput>, outputs: outputs as! Array<TransactionOutput>)
        let signedTransaction = transaction!.sign(privateKey: Data(hex:"36775b4bafc4d906c9035903785fcdb4f0e9e7b5d6f6f1a4b001bb5a4396c391"))
        let completedSendExpectation = expectation(description: "Completed")
        serviceUTXO().sendRawTX(transaction: signedTransaction!, onTestnet: true) { (result) in
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
        waitForExpectations(timeout: 30, handler: nil)
    }
}
