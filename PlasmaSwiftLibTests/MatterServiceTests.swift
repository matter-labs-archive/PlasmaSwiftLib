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
        ServiceUTXO().getListUTXOs(for: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                DispatchQueue.main.async {
                    print(r)
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
        ServiceUTXO().getListUTXOs(for: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                XCTAssert(r.count > 0)
                let input = r[0].toTransactionInput()!
                let inputs = [input]
                let outputs = [TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, amount: input.amount)!]
                let transaction = Transaction(txType: .split, inputs: inputs, outputs: outputs)
                let signedTransaction = transaction!.sign(privateKey: privKey)
                XCTAssertEqual(EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!, signedTransaction!.sender)
                ServiceUTXO().sendRawTX(transaction: signedTransaction!, onTestnet: true) { (result) in
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
